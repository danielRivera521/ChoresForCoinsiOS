//
//  ProtectedViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/15/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ProtectedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if let googleUserName = GIDSignIn.sharedInstance().currentUser.profile.name{
            print (googleUserName)
        }
        
    }
    
}
