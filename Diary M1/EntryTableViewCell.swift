//
//  EntryTableViewCell.swift
//  Diary M1
//
//  Created by Christian Alvarez on 30/08/2017.
//  Copyright © 2017 Christian Alvarez. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var entryPhoto: UIImageView!
    @IBOutlet weak var dateString: UILabel!
    @IBOutlet weak var titleString: UILabel!
    @IBOutlet weak var textString: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
