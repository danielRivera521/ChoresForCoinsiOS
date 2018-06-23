//
//  ChoreDetailsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ChoreDetailsViewController: UIViewController {
    
    @IBOutlet weak var choreNameLabel: UILabel!
    @IBOutlet weak var choreImageImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var choreValueLabel: UILabel!
    @IBOutlet weak var choreNoteTextView: UITextView!
    @IBOutlet weak var editUIButton: UIButton!
    @IBOutlet weak var childRedeemView: UIView!
    
    
    @IBOutlet weak var completedBtn: UIButton!
    
    @IBOutlet weak var headerUserNameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    
    var coinValue: Int = 0
    var choreCoinValue: Int = 0
    
    var choreId: String?
    var userID: String?
    var parentID: String?
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var runningTotal = 0
    var isParent = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        childRedeemView.isHidden = true
        
        if let username = Auth.auth().currentUser?.displayName{
            headerUserNameLabel.text = username
            getChoreData()
        }
        completedBtn.isEnabled = true
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //gets the custom parent id created in the registration
        getParentId()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRunningTotal()
    }
    
    func getRunningTotal(){
        
        getChildren()
        getCoinTotals()
    }
    
    
    func getChoreData(){
        
        let ref = Database.database().reference()
        
        ref.child("chores").child(choreId!).observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            let chorName = value?["chore_name"] as? String
            let chorDescript = value?["chore_description"] as? String
            let startChor = value?["start_date"] as? String
            let chorDue = value?["due_date"] as? String
            let chorValue = value?["number_coins"] as? String
            let choreNote = value?["chore_note"] as? String
            let imageLocale = value?["chore_picture"] as? String
            let chorComplete = value?["chore_completed"] as? Bool
            
            if let choreName = chorName{
                self.choreNameLabel.text = choreName
            }
            if let choreDescript = chorDescript{
                self.choreDescriptionTextView.text = "Chore Description: " + choreDescript
            }
            
            if let startChore = startChor {
                self.startDateLabel.text = startChore
            }
            if let choreDue = chorDue {
                self.dueDateLabel.text = choreDue
            }
            if let note = choreNote {
                
                self.choreNoteTextView.text = "Chore Note: " + note
                
            }
            
            if let choreValue = chorValue{
                self.choreCoinValue = Int(choreValue)!
                self.choreValueLabel.text = choreValue
            }
            
            self.usernameLabel.text = ""
            
            if let choreComplete = chorComplete {
                if choreComplete {
                    self.completedBtn.isEnabled = false
                    self.completedBtn.setTitle("Chore Completed", for: UIControlState.normal)
                }
            }
            
            
        }
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
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func markComplete(_ sender: UIButton) {
        
        let ref = Database.database().reference().child("chores")
        
        ref.child("\(choreId!)").updateChildValues(["chore_completed" : true])
        addCoins()
        dismiss(animated: true, completion: nil)
    }
    
    func addCoins (){
    
        let databaseRef = Database.database().reference()
    
        var bonusOn = false
        var multiplier: Double = 1
        databaseRef.child("app_settings").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let isBonus = value?["bonus_toggled"] as? Bool
            if let unwrappedIsBonus = isBonus {
                bonusOn = unwrappedIsBonus
            }
            
            let multiply = value?["multiplier_value"] as? Double
            if let mValue = multiply {
           
                multiplier = mValue
            }
        }
        if bonusOn {
            var choreCoinVal: Double = Double(choreCoinValue)
            
            choreCoinVal *= multiplier
            
            choreCoinValue = Int(choreCoinVal)
        }
        coinValue += choreCoinValue
        if let uid = Auth.auth().currentUser?.uid{
            databaseRef.child("running_total").child(uid).updateChildValues(["coin_total": self.coinValue])
        }
        
        
    }
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.performSegue(withIdentifier: "toCoinFromChoreDetails", sender: nil)
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
