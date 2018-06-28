//
//  AddChoreViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class AddChoreViewController: UIViewController {
    
    @IBOutlet weak var choreImageUIButton: UIButton!
    @IBOutlet weak var choreNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!    
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var choreValueTextField: UITextField!
    @IBOutlet weak var choreNoteTextView: UITextView!
    @IBOutlet weak var childRedeemView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    var isFirstLoad = true
    var coinValue = 0
    
    var ref: DatabaseReference?
    
    // create date picker
    let picker = UIDatePicker()
    // array to hold all users with same generatedId
    var family = [UserModel] ()
    var currentUID: String?
    var userID: String?
    var parentID: String?
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var runningTotal = 0
    var isParent = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        childRedeemView.isHidden = true
        
        if (Auth.auth().currentUser?.displayName) != nil{
            displayHeaderName()
            ref = Database.database().reference()
            
            // set up date pickers
            createDatePickerStart()
            createDatePickerDue()
            
            //acquire parent ID
            getParentId()
        }
        
        // get profile photo for profile button
        getPhoto()
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRunningTotal()
        getPhoto()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func changeChorePicture(_ sender: UIButton) {
    }
    
    //populates the running total for the user's coins in the top right hand corner
    func getRunningTotal(){
        
        getChildren()
        getCoinTotals()
    }
    func createDatePickerStart() {
        // create toolbar for done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedStart))
        toolbar.setItems([done], animated: false)
        
        startDateTextField.inputAccessoryView = toolbar
        startDateTextField.inputView = picker
        
        // format picker for date only
        picker.datePickerMode = .date
    }
    
    func createDatePickerDue() {
        // create toolbar for done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedDue))
        toolbar.setItems([done], animated: false)
        
        dueDateTextField.inputAccessoryView = toolbar
        dueDateTextField.inputView = picker
        
        // format picker for date only
        picker.datePickerMode = .date
    }
    
    @objc func donePressedStart() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: picker.date)
        
        startDateTextField.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    @objc func donePressedDue() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: picker.date)
        
        dueDateTextField.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    @IBAction func saveChore(_ sender: UIButton) {
        //creates a new chore reference
        let newChoreRef = ref?.child("chores").childByAutoId()
        
        //creates a new key
        let currentChoreId = newChoreRef?.key
        
        //if the key is valid. Takes the information inputted or generated by the form and creates a new chore.
        if let currentChoreId = currentChoreId {
            ref?.child("chores/\(currentChoreId)/chore_name").setValue(choreNameTextField.text)
            ref?.child("chores/\(currentChoreId)/user_name").setValue(usernameTextField.text)
            ref?.child("chores/\(currentChoreId)/chore_description").setValue(choreDescriptionTextView.text)
            ref?.child("chores/\(currentChoreId)/start_date").setValue(startDateTextField.text)
            ref?.child("chores/\(currentChoreId)/due_date").setValue(dueDateTextField.text)
            ref?.child("chores/\(currentChoreId)/chore_note").setValue(choreNoteTextView.text)
            
            ref?.child("chores/\(currentChoreId)/number_coins").setValue(choreValueTextField.text)
            
            if let pID = self.parentID{
                ref?.child("chores/\(currentChoreId)/parent_id").setValue(pID)
            }
            createAssignmentID(choreID: currentChoreId)
            
        }
        
        // TODO: Add alert that says the chore was saved
        
        // clear the text fields
        choreNameTextField.text = nil
        usernameTextField.text = nil
        choreDescriptionTextView.text = nil
        startDateTextField.text = nil
        dueDateTextField.text = nil
        choreValueTextField.text = nil
        choreNoteTextView.text = nil
        
    }
    //creates initial assignment
    func createAssignmentID(choreID: String){
        let newAssignRef = ref?.child("chore_assignment").childByAutoId()
        let assignID = newAssignRef?.key
        if let assignID = assignID {
            ref?.child("chore_assignment/\(assignID)/chore_id").setValue(choreID)
            ref?.child("chore_assignment/\(assignID)/chore_completed").setValue(false)
        }
        
    }
    
    //gets the parent generated id from the user's node in the database
    func getParentId(){
        let userID = Auth.auth().currentUser?.uid
        
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
        
        let DatabaseRef = Database.database().reference()
        if let uid = userID{
            DatabaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                //gets the image URL from the user database
                if let profileURL = value?["profile_image_url"] as? String{

                    self.profileButton.loadImagesUsingCacheWithUrlString(urlString: profileURL, inViewController: self)
                     //turn button into a circle
                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                    self.profileButton.layer.masksToBounds = true
                    
                }
            }
        }
    }
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.performSegue(withIdentifier: "toCoinFromAddChore", sender: nil)
                } else {
                    self.childRedeemView.isHidden = false
                }
            }
        })
    }
    
    @IBAction func childRedeem(_ sender: UIButton) {
        // zero out coin total and update db
        
        childRedeemView.isHidden = true
    }
    
}
