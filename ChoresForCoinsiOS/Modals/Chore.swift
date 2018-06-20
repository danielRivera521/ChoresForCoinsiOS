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
    var name: String
    var completed: Bool?
    
    init(dictionary: [String : AnyObject], key: String){
        self.key = key
        self.name = dictionary["chore_name"] as! String
       
        
        if dictionary["chore_completed"] == nil{
            self.completed =  false
        } else {
            self.completed = Bool(dictionary["chore_completed"] as! String)
        }
    }
}
