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
    
    @IBOutlet weak var bgImage: UIImageView!
    
    var authUI: FUIAuth?
    var ref: DatabaseReference?
    var isParent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getBackground()
        
        ref = Database.database().reference()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getBackground() {
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("user/\(uid)/bg_image").observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? Int {
                    switch value {
                    case 0:
                        self.bgImage.image = #imageLiteral(resourceName: "whiteBG")
                    case 1:
                        self.bgImage.image = #imageLiteral(resourceName: "orangeBG")
                    case 2:
                        self.bgImage.image = #imageLiteral(resourceName: "greenBG")
                    case 3:
                        self.bgImage.image = #imageLiteral(resourceName: "redBG")
                    case 4:
                        self.bgImage.image = #imageLiteral(resourceName: "purpleBG")
                    default:
                        self.bgImage.image = #imageLiteral(resourceName: "whiteBG")
                    }
                }
            }
        }
        
        
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
}
