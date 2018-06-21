//
//  Chore.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/20/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation

class Chore{
    
    var key: String
    var name: String?
    var choreUsername: String?
    var dueDate: String?
    var completed: Bool?
    
    init(dictionary: [String : AnyObject], key: String){
        self.key = key
        if let choreName = dictionary["chore_name"] as? String {
            self.name = choreName
        }
        
        if let choreUsername = dictionary["chore_username"] as? String {
            self.choreUsername = choreUsername
        }
        
        if let dueDate = dictionary["due_date"] as? String {
            self.dueDate = dueDate
        }
        
        if dictionary["chore_completed"] == nil{
            self.completed =  false
        } else {
            if let choreCompleted = dictionary["chore_completed"] as? Bool {
                self.completed = choreCompleted
            }
        }
    }
}
