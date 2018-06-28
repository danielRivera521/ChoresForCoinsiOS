//
//  ChoreEditViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ChoreEditViewController: UIViewController {
    
    @IBOutlet weak var choreImageUIButton: UIButton!
    @IBOutlet weak var choreNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var choreValueTextField: UITextField!
    @IBOutlet weak var choreNoteTextView: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    var ref: DatabaseReference?
    var userID: String?
    var parentID: String?
    var idFound = false
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var runningTotal = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        checkDatabase()
        
        //gets the custom parent id created in the registration
        getParentId()
        
        // get photo for profile button
        getPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRunningTotal()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDatabase() {
        
        let databaseRef = Database.database().reference().child("user")
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.observe(.value) { (snapshot) in
                
                if snapshot.exists(){
                    if let userIdDictionary = snapshot.value as? NSDictionary{
                        for id in userIdDictionary.keyEnumerator(){
                            if let userID = id as? String{
                                if userID == uid {
                                    // user is in database
                                    self.idFound = true
                                    self.displayHeaderName()
                                    return
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
        
        
        if !idFound {
            
            //user not in the database. Registration segue is called
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "parentChildVC") as? ParentChildViewController
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
        
    }
    
    func displayHeaderName(){
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                if let name = value?["user_name"] as? String{
                    self.usernameLabel.text = name
                }
            }
        }
    }
    
    func getRunningTotal(){
        
        getChildren()
        getCoinTotals()
    }
    
    //gets the parent generated id from the user's node in the database
    func getParentId(){
        if let actualUID = userID{
            _ = Database.database().reference().child("user").child(actualUID).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let id = value?["parent_id"] as? String
                if let actualID = id{
                    self.parentID = actualID
                }
            }
        }
        
    }
    
    // gets all children with same parent id as user
    func getChildren() {
        children.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictUsers = dictRoot["user"] as? [String:AnyObject] ?? [:]
            var count = 0
            for key in Array(dictUsers.keys) {
                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                self.children = self.children.filter({$0.parentid == self.parentID})
                self.children = self.children.filter({$0.userparent! == false})
                
                count += 1
            }
        }
        
    }
    
    func getCoinTotals() {
        coinTotals.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictRunningTotal = dictRoot["running_total"] as? [String:AnyObject] ?? [:]
            var count = 0
            for key in Array(dictRunningTotal.keys) {
                self.coinTotals.append(RunningTotal(dictionary: (dictRunningTotal[key] as? [String:AnyObject])!, key: key))
                
                count += 1
            }
            
            var sumTotal = 0
            
            for coinTotal in self.coinTotals {
                for child in self.children {
                    if coinTotal.userid == child.userid {
                        if let total = coinTotal.cointotal {
                            sumTotal += total
                        }
                    }
                }
            }
            
            self.coinAmtLabel.text = String(sumTotal)
        }
    }
    
    func getPhoto() {
        var uid = ""
        if let UID = Auth.auth().currentUser?.uid {
            uid = UID
        }
        
        Database.database().reference().child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? [String:Any] {
                // get profile picture
                if let filename = val["profilePicture"] as? String {
                    let fileref = Storage.storage().reference().child(filename)
                    fileref.getData(maxSize: 100000000, completion: { (data, error) in
                        if error == nil {
                            if data != nil {
                                let img = UIImage.init(data: data!)
                                
                                // make sure UI is getting updated on Main thread
                                DispatchQueue.main.async {
                                    self.profileButton.setBackgroundImage(img, for: .normal)
                                    // turn button into a circle
                                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                                    self.profileButton.layer.masksToBounds = true
                                }
                                
                            }
                        } else {
                            print(error?.localizedDescription)
                        }
                    })
                }
            }
        }
    }
    
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeChorePicture(_ sender: UIButton) {
    }
    
    @IBAction func deleteChore(_ sender: UIButton) {
    }
    
    @IBAction func saveChore(_ sender: UIButton) {
    }
    
}
