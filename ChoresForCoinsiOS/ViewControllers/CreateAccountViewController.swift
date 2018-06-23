//
//  CreateAccountViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import KeychainSwift
import GoogleSignIn
import FBSDKLoginKit


class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var parentIDTextField: UITextField!
    
    var isParent = false
    var name: String?
    var email: String?
    var parentKey: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        name = Auth.auth().currentUser?.displayName
        email = Auth.auth().currentUser?.email
        
        usernameTextField.text = name
        emailTextField.text = email
        if isParent{
            parentIDTextField.text = createParentID()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
        //creates account in database
        
        createAccount()
       
        self.performSegue(withIdentifier: "goToChoreList", sender: nil)
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createAccount(){
        
        let userID = Auth.auth().currentUser?.uid
        let name = Auth.auth().currentUser?.displayName
        let databaseRef = Database.database().reference().child("user")
        
        //checks the value of isParent and creates account in database
        if isParent{
            let newUser = ["user_id":userID!,
                           "parent_id": self.createParentID(),
                           "user_name": name!,
                           "user_parent":true] as [String : Any]
            
            
            databaseRef.child(userID!).setValue(newUser)
            
        } else {
            if let key = parentIDTextField.text{
                let newUser = ["user_id":userID!,
                               "parent_id": key,
                               "user_name": name!,
                               "user_parent":false] as [String : Any]
                let newRunningTotal = ["child_id":userID!,"coin_total":0] as [String : Any]
                databaseRef.child(userID!).setValue(newUser)
                Database.database().reference().child("running_total").child(userID!).setValue(newRunningTotal)
                
            } else {
                AlertController.showAlert(self, title: "Missing Info", message: "Please ensure all fields are filled out")
            }
        }
    }
    
    //code to generate a parent id using the name portion of email and last 5 characters from UID
    func createParentID() -> String{
        
        var generatedID = ""
        
        if let email = Auth.auth().currentUser?.email{
            
            if let name = email.components(separatedBy: CharacterSet(charactersIn: ("@0123456789"))).first {
                
                if let uid = Auth.auth().currentUser?.uid{
                    let last5 = uid.suffix(5)
                    generatedID = name + last5
                }
            }
        }
        
        return generatedID
    }
    
}
