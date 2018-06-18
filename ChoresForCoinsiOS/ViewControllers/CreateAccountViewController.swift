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
    @IBOutlet weak var passwordTextField: UITextField!
    
    var isParent = false
    var name: String?
    var email: String?
    var password: String?
    var parentKey: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        name = Auth.auth().currentUser?.displayName
        email = Auth.auth().currentUser?.email
        
        usernameTextField.text = name ?? ""
        emailTextField.text = email ?? ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
        //creates account in database
        if validateText(){
            createAccount()
        }
        // dismiss back to tab bar controller
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createAccount(){
    
        if let id = Auth.auth().currentUser?.uid {
    
            let userID = id
            let name = Auth.auth().currentUser?.displayName
            
            addToDatabase(userID: userID, name: name!)
            
        } else {
            if isValidEmail(){

            let email = emailTextField.text
            let password = passwordTextField.text
                Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                    if let error = error {
                        print(error)
                        return
                    } else {
                        let id = user?.user.uid
                        let name = self.usernameTextField.text
                        self.addToDatabase(userID: id!, name: name!)
                        
                    }
                }
            
            
            }
        }
        

    }
    
    func addToDatabase(userID: String,name: String){
        
        let databaseRef = Database.database().reference().child("user")
        
        //checks the value of isParent and creates account in database
        if isParent{
            let newUser = ["user_id":userID,
                           "parent_id": self.createParentID(),
                           "user_name": name,
                           "user_parent":true] as [String : Any]
            
            
            databaseRef.child(userID).setValue(newUser)
            
        } else {
            let newUser = ["user_id":userID,
                           "parent_id": self.createParentID(),
                           "user_name": name,
                           "user_parent":false] as [String : Any]
            
            databaseRef.child(userID).setValue(newUser)
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
    
    //test if email field is in an email format
    func isValidEmail() -> Bool {
        let testStr = emailTextField.text
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func validateText() -> Bool{
        
        return (emailTextField.text?.isEmpty)! && (passwordTextField.text?.isEmpty)! && (usernameTextField.text?.isEmpty)!
    
    }
    
}
