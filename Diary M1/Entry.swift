//
//  Entry.swift
//  Diary M1
//
//  Created by Christian Alvarez on 30/08/2017.
//  Copyright © 2017 Christian Alvarez. All rights reserved.
//

import UIKit
import CoreData

class Entry {
    //MARK: Properties
    var title: String
    var text: String
    var picture: UIImage?
    var date: Date
    
    //MARK: Types
    struct PropertyKey {
        static let title = "title"
        static let text = "text"
        static let picture = "picture"
        static let date = "date"
    }
    
    init?(title: String, text: String, picture: UIImage?, date: Date) {
        guard !title.isEmpty else {
            return nil
        }
        self.title = title
        self.text = text
        self.picture = picture
        self.date = date
    }
    
}

