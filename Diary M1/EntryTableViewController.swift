//
//  EntryTableViewController.swift
//  Diary M1
//
//  Created by Christian Alvarez on 30/08/2017.
//  Copyright © 2017 Christian Alvarez. All rights reserved.
//

import UIKit
import os.log
import CoreData

class EntryTableViewController: UITableViewController {
    //MARK: Properties
    //Core Data Managed Objects for us to work with
    var entriesCoreData: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add default edit button item
        navigationItem.leftBarButtonItem = editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        //Load data. If there's none, populate with sample data
        loadEntries()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entriesCoreData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EntryTableViewCell", for: indexPath) as? EntryTableViewCell else {
            fatalError("Dequeued cell is not an EntryTableViewCell instance")
        }
        //Gets current entry from core data stack
        let diaryEntry = entriesCoreData[indexPath.row]
        
        //Sets cell's content based on entry
        cell.titleString.text = diaryEntry.value(forKeyPath: Entry.PropertyKey.title) as? String
        cell.textString.text = diaryEntry.value(forKeyPath: Entry.PropertyKey.text) as? String
        cell.entryPhoto.image = diaryEntry.value(forKeyPath: Entry.PropertyKey.picture) as? UIImage
        let dateSet = diaryEntry.value(forKeyPath: Entry.PropertyKey.date) as? Date
        cell.dateString.text = getString(from: dateSet!)
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            //Delete entry from core data stack
            managedContext.delete(entriesCoreData[indexPath.row])
            // Delete the row from table
            entriesCoreData.remove(at: indexPath.row)
            do { //3
                try managedContext.save()
                //4
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch let error as NSError {
                print("Saving error: \(error)")
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddEntry":
            os_log("Adding a new entry.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let EntryDetailViewController = segue.destination as? ViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedEntryCell = sender as? EntryTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedEntryCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            //Passes an entry file (not the core data stack) to the view controller to work with.
            EntryDetailViewController.entry = getEntry(from: entriesCoreData[indexPath.row])
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    //MARK: Actions
    
    @IBAction func unwindToEntryList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ViewController, let entry = sourceViewController.entry {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //Update an existing entry
                editEntry(with: selectedIndexPath, title: entry.title, text: entry.text, date: entry.date, picture: entry.picture)
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                //add a new entry
                let newIndexPath = IndexPath(row: entriesCoreData.count, section: 0)
                //Save entry in core data stack
                saveEntry(title: entry.title, text: entry.text, date: entry.date, picture: entry.picture)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    //MARK: Private Methods
    private func loadEntries() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "DiaryEntry")
        //3
        do {
            entriesCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if entriesCoreData.isEmpty {
            //Populate entries with sample data if diary entries are empty
            let defaultEntry = Entry(title: "Your Adventure Starts Here.", text: "Start writing!", picture: #imageLiteral(resourceName: "entry1") , date: Date())!
            saveEntry(title: defaultEntry.title, text: defaultEntry.text, date: defaultEntry.date, picture: defaultEntry.picture)
        }
        
    }
    //MARK: Core data save and edit entries
    
    private func saveEntry(title: String, text: String, date: Date, picture: UIImage?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //1
        let managedContext = appDelegate.persistentContainer.viewContext
        //2
        let entity = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedContext)!
        let diaryEntry = NSManagedObject(entity: entity, insertInto: managedContext)
        //3
        diaryEntry.setValue(title, forKeyPath: Entry.PropertyKey.title)
        diaryEntry.setValue(text, forKeyPath: Entry.PropertyKey.text)
        diaryEntry.setValue(picture, forKeyPath: Entry.PropertyKey.picture)
        diaryEntry.setValue(date, forKeyPath: Entry.PropertyKey.date)
        //add to managed object array before saving
        entriesCoreData.append(diaryEntry)
        //4
        do {
            try managedContext.save()
            print("Saved.")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    //Replaces entry in indexpath with a new entry using the values provided.
    private func editEntry(with indexPath: IndexPath, title: String, text: String, date: Date, picture: UIImage?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //Delete old core data entry
        managedContext.delete(entriesCoreData[indexPath.row])
        
        do {
            try managedContext.save()
            print("Old data deleted.")
        } catch let error as NSError {
            print("Could not delete old data. \(error), \(error.userInfo)")
        }
        
        //Commit changes by adding it into core data array
        
        let entity = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedContext)!
        let diaryEntry = NSManagedObject(entity: entity, insertInto: managedContext)
        //3
        diaryEntry.setValue(title, forKeyPath: Entry.PropertyKey.title)
        diaryEntry.setValue(text, forKeyPath: Entry.PropertyKey.text)
        diaryEntry.setValue(picture, forKeyPath: Entry.PropertyKey.picture)
        diaryEntry.setValue(date, forKeyPath: Entry.PropertyKey.date)
        //4
        
        //Update core data entry array with new information
        entriesCoreData[indexPath.row] = diaryEntry
        do {
            try managedContext.save()
            print("Editing successful")
        } catch let error as NSError {
            print("Could not finish editing \(error), \(error.userInfo)")
        }
    }

    //Returns date as string
    private func getString(from date: Date) -> String {
        let formatter = DateFormatter()
        // Set format of date
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: date )
        return dateString
    }
    
    private func getEntry(from entryManagedObject: NSManagedObject) -> Entry! {
        let title = entryManagedObject.value(forKeyPath: Entry.PropertyKey.title) as? String
        let text = entryManagedObject.value(forKeyPath: Entry.PropertyKey.text) as? String
        let picture = entryManagedObject.value(forKeyPath: Entry.PropertyKey.picture) as? UIImage
        let date = entryManagedObject.value(forKeyPath: Entry.PropertyKey.date) as! Date
        return Entry(title: title!, text: text!, picture: picture, date: date)
    }
    
    
    
}



