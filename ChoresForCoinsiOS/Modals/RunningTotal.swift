//
//  RunningTotal.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/23/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation

class RunningTotal {
    var key: String
    var userid: String?
    var cointotal: Int?
    var redeemedTotal: Int?
    
    init(dictionary: [String:AnyObject], key: String) {
        self.key = key
        if let userid = dictionary["child_id"] as? String {
            self.userid = userid
        }
        if let cointotal = dictionary["coin_total"] as? Int {
            self.cointotal = cointotal
        }
        if let redeemedTotalAmt  = dictionary["redeemed_coins"] as? Int {
            self.redeemedTotal = redeemedTotalAmt
        }
    }
}
