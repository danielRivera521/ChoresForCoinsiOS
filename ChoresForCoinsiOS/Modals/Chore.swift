//
//  Chore.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/20/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation

//Chore class will be used to access the data from the firebase database and put it into an array of chores. This will help with accessing individual portions of data for each chore.


class Chore{
    
    var key: String
    var name: String?
    var choreUsername: String?
    var dueDate: String?
    var completed: Bool?
    var parentID: String?
    var choreURL: String?
    var chorePastDue: String?
    var choreParentNotified: String?
    var choreCompletedNotified: String?
    var choreValue: Int?
    var childID: String?
    var choreCompletedDate: String?
    
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
        
        if let parentid = dictionary["parent_id"] as? String{
            self.parentID = parentid
        }
        
        if dictionary["chore_completed"] == nil{
            self.completed =  false
        } else {
            if let choreCompleted = dictionary["chore_completed"] as? Bool {
                self.completed = choreCompleted
            }
        }
        
        if let choreImage = dictionary["image_url"] as? String {
            self.choreURL = choreImage
        }
        
        if let chorePastDue = dictionary["past_due"] as? String {
            self.chorePastDue = chorePastDue
        }
        
        if let parentNotified = dictionary["past_due_notified"] as? String {
            self.choreParentNotified = parentNotified
        }
        
        if let choreCompletedNotified = dictionary["chore_completed_notified"] as? String{
            self.choreCompletedNotified = choreCompletedNotified
        }
        
        if let choreVal = dictionary["number_coins"] as? String {
            self.choreValue = Int(choreVal)
        }
        
        if let childID = dictionary["assigned_child_id"] as? String {
            self.childID = childID
        }
        
        if let choreCompletedDate = dictionary["date_completed"] as? String{
            self.choreCompletedDate = choreCompletedDate
        }
    }
}
