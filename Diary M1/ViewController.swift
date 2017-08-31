//
//  ViewController.swift
//  Shows individual diary entries. This allows users to edit an exisiting entry or create a new one
//  depending on the button pressed back in the entry table.
//  Diary M1
//
//  Created by Christian Alvarez on 30/08/2017.
//  Copyright © 2017 Christian Alvarez. All rights reserved.
//

import UIKit
import os.log
import CoreData

class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    
    //Image Picker/Display
    @IBOutlet weak var pictureForEntry: UIImageView!
    //Title field
    @IBOutlet weak var titleTextField: UITextField!
    //Text field
    @IBOutlet weak var textTextView: UITextView!
    //Date Picker
    @IBOutlet weak var entryDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /*
     This value is either passed by 'EntryTableViewController' in 'prepare(for:sender)' or constructed as part of adding a new entry.
     */
    var entry: Entry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textTextView.delegate = self
        titleTextField.delegate = self
        
        //Set up views if editing an existing entry
        if let entry = entry {
            navigationItem.title = entry.title
            titleTextField.text = entry.title
            textTextView.text = entry.text
            entryDatePicker.date = entry.date
            pictureForEntry.image = entry.picture
        }
        
        //Do additional setup for text view (text) so that it looks like the text field (title)
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        textTextView.layer.borderWidth = 0.5
        textTextView.layer.borderColor = borderColor.cgColor
        textTextView.layer.cornerRadius = 5.0
        
        //Enable save button only if the text field has a valid entry title
        updateSaveButtonState()
    }
    //MARK: Tap recognizer to activate image picker
    @IBAction func selectImageFromPhotoGallery(_ sender: UITapGestureRecognizer) {
        
        //Remove the keyboard
        titleTextField.resignFirstResponder()
        textTextView.resignFirstResponder()
        
        //Set up image picker view controller
        let imagePickerController = UIImagePickerController()
        //Allows user to pick photos from the photo library
        imagePickerController.sourceType = .photoLibrary
        //Sets self as the delegate so that the imagePickerController function is used
        imagePickerController.delegate = self
        //Present the finished view controller!
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    //MARK: Image Picker View Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        //Set UIImage with selected image
        pictureForEntry.image = selectedImage
        
        //Dismiss picker
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: Text View Delegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //If enter key was pressed, resign first responder status
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }
    
    //MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //If enter key was pressed, resign first responder status
        titleTextField.resignFirstResponder()
        return true;
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the save button when editing
        saveButton.isEnabled = false
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        //Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddEntryMode = presentingViewController is UINavigationController
        if isPresentingInAddEntryMode {
            //If cancel was pressed while in creation mode, dismiss view
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            //If cancel was pressed while editing, pop view controller from stack
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The View Controller is not inside a navigation controller.")
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Check if button references the same thing as saveButton. If not, assume that the user pressed cancel
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log:OSLog.default, type:.debug)
            return
        }
        //Get values from fields so we can save it and send it to the table view controller.
        let title = titleTextField.text ?? ""
        let text = textTextView.text ?? ""
        let picture = pictureForEntry.image
        let date = entryDatePicker.date
        entry = Entry(title: title, text: text, picture: picture, date: date)
    }
  
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    

    

 
    

}

