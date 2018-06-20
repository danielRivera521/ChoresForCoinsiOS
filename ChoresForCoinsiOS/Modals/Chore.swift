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
    
    init(key: String, name: String, completed: Bool?){
        self.key = key
        self.name = name
       
        
        if completed == nil{
            self.completed =  false
        } else {
            self.completed = completed
        }
    }
}
