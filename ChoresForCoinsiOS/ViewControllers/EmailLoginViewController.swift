//
//  EmailLoginViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/15/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import KeychainSwift


class EmailLoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //if the user already signed into application then the uid is used to access the app and bypasses the signin page.
        let keyChain = DataService().keyChain
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "overviewVC", sender: nil)
        }
    }

  

    func CompleteSignIn(id: String){
        //assigns uid to keychain
        let keyChain = DataService().keyChain
        keyChain.set(id, forKey: "uid")
    }
    
    //Code signin Button
    @IBAction func signInBtn(_ sender: UIButton){
        if let email = emailField.text, let password = passwordField.text {
            
            //Firebase coding
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
                if let error = error {
                    print(error)
                    //checks for an error and displays an alert message that will then take the user to the root login page
                    
                    self.alertBuilder(message: "User account not present. Please select sign up or use another")
                    self.gotoRootViewController()
                    return
            
                } else {
                    //capture uid of the current user and perform segue
                    self.CompleteSignIn(id: (Auth.auth().currentUser?.uid)!)
                    self.performSegue(withIdentifier: "overviewVC", sender: nil)
                }
                
            }
        }
        
    }
    
    func alertBuilder(message: String) {

        //create the alert controller
        let alertController = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        
        //create the alert action
        let okAlert = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            
            NSLog("OK Pressed")
            
        }
        //add the action
        alertController.addAction(okAlert)
        
        //show the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    //go to homescreen
    func gotoRootViewController(){
        
        if self.presentingViewController != nil {
            self.dismiss(animated: false) {
                self.navigationController?.popToRootViewController(animated: true)
                
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }


}
