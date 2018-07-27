//
//  ChildUser.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/23/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation
//childUser class will be used to access the data from the firebase database and put it into an array of childUsers. This will help with accessing individual portions of data for each child.

class ChildUser {
    var key: String
    var userid: String?
    var username: String?
    var userparent: Bool?
    var parentid: String?
    var isRedeem: Bool?
    
    init(dictionary: [String:AnyObject], key: String) {
        self.key = key
        if let userid = dictionary["user_id"] as? String {
            self.userid = userid
        }
        if let username = dictionary["user_name"] as? String {
            self.username = username
        }
        if let userparent = dictionary["user_parent"] as? Bool {
            self.userparent = userparent
        }
        if let parentid = dictionary["parent_id"] as? String {
            self.parentid = parentid
        }
        if let isRedeem = dictionary["isRedeem"] as? Bool {
            self.isRedeem = isRedeem
        }
        
    }
}
