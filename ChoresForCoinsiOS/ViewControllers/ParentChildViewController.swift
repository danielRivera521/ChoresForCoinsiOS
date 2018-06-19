//
//  ParentChildViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/18/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ParentChildViewController: UIViewController, FUIAuthDelegate {
    
    var authUI: FUIAuth?
    var ref: DatabaseReference?
    var isParent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ref = Database.database().reference()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func parentRegistrationBtn(_ sender: UIButton) {
        
        isParent = true
    }
    
    @IBAction func childRegistrationBtn(_ sender: UIButton) {
        isParent = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createParentSegue" {
            isParent = true
        }
        if segue.identifier == "createChildSegue" {
            isParent = false
        }
        
        if let createAccountVC = segue.destination as? CreateAccountViewController{
            
            createAccountVC.isParent = isParent
            
        }
        
    }
    
//    @IBAction func createParentOrChild(_ sender: UIButton) {
//        switch sender.tag {
//        case 1:
//            // Handle Parent
//            //get user id
//            let user = Auth.auth().currentUser
//            if let user = user {
//                let uid = user.uid
//                
//                ref?.child("user").child(uid).setValue(["user_parent":"true"])
//            }
//        case 2:
//            // Handle Child
//            //get user id
//            let user = Auth.auth().currentUser
//            if let user = user {
//                let uid = user.uid
//                
//                ref?.child("user").child(uid).setValue(["user_parent":"false"])
//            }
//        default:
//            break
//        }
//        
//        performSegue(withIdentifier: "goToOverViewFromPC", sender: self)
//    }
}
