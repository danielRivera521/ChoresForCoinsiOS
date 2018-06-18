//
//  DataService.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/15/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import KeychainSwift
let DB_BASE = Database.database().reference()

class DataService {
    
    private var _keyChain = KeychainSwift()
    private var _refDB = DB_BASE
    
    
    var keyChain: KeychainSwift {
        
        get {
            return _keyChain
        } set {
            _keyChain = newValue
        }
    }
    
}
