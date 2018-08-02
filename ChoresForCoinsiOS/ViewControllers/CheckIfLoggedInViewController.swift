//
//  CheckIfLoggedInViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 8/1/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class CheckIfLoggedInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                print("\(user)")
                self.performSegue(withIdentifier: "toMain", sender: self)
            } else {
                // No user is signed in.
                self.performSegue(withIdentifier: "toSignInFromRoot", sender: self)
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
