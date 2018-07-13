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


class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var parentIDTextField: UITextField!
    @IBOutlet weak var bgImage: UIImageView!
    
    var isParent = false
    var name: String?
    var email: String?
    var parentKey: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        parentIDTextField.delegate = self
        
        getBackground()
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        
        return true
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss keyboard when user touches outside of keyboard
        self.view.endEditing(true)
    }
    
    //code to generate a parent id using the name portion of email and last 5 characters from UID
    func createParentID() -> String{
        
        var generatedID = ""
        
        if let email = Auth.auth().currentUser?.email{
            
            if let name = email.components(separatedBy: CharacterSet(charactersIn: ("@0123456789"))).first {
                //only use the letters and numbers in an email address
                
                //create a custom character set of just letters and numbers.
                var alphaNumericCharacterSet = CharacterSet.letters
                alphaNumericCharacterSet.formUnion(CharacterSet.decimalDigits)
                
                //if the string name has characters not in the characterset (inverted) it will not be joined to the string.
                let newName = name.components(separatedBy: alphaNumericCharacterSet.inverted).joined()
                if let uid = Auth.auth().currentUser?.uid{
                    let last5 = uid.suffix(5)
                    generatedID = newName + last5
                }
            
            }
        }
        
        return generatedID
    }
    
}
