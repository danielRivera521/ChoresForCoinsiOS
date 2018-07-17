//
//  ChoresDetailSplitViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 7/17/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import MobileCoreServices

class ChoresDetailSplitViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var choreNameLabel: UILabel!
    @IBOutlet weak var choreImageImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var choreValueLabel: UILabel!
    @IBOutlet weak var choreNoteTextView: UITextView!
    @IBOutlet weak var editUIButton: UIButton!
    @IBOutlet weak var completedBtn: UIButton!
    @IBOutlet weak var detailImageHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: Properties
    
    //coinValue and choreCoinValue variables set to 0
    var coinValue: Int = 0
    var choreCoinValue: Int = 0
    
    //choreID, userID and parentID variables to hold their respective variables from Firebase
    var choreId: String?
    var userID: String?
    var parentID: String?
    var runningTotal = 0
    var isParent = true
    var isActiveUserParent = false
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var isPastDue = false
    
    private var imagePicker: UIImagePickerController!
    
    
    // MARK: ViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        getChoreData()
        
        completedBtn.isEnabled = true
        
        //gets the custom parent id created in the registration
        getParentId()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isUserParent()
    }

    
    // MARK: Custom Methods
    
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
            let imageLocale = value?["image_url"] as? String
            let chorComplete = value?["chore_completed"] as? Bool
            let chorePastDue = value?["past_due"] as? String
            let choreUserName = value?["user_name"] as? String
            
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
                if let choreVal = Int(choreValue) {
                    self.choreCoinValue = choreVal
                }
                self.choreValueLabel.text = choreValue
            }
            if let userNameString = choreUserName{
                self.usernameLabel.text = userNameString
            } else {
                self.usernameLabel.text = ""
            }
            
            if let choreComplete = chorComplete {
                if choreComplete {
                    self.completedBtn.isEnabled = false
                    self.completedBtn.setTitle("Chore Completed", for: UIControlState.normal)
                }
            }
            
            if let choreImageURL = imageLocale {
                
                self.choreImageImageView.loadImagesUsingCacheWithUrlString(urlString: choreImageURL, inViewController: self)
            } else {
                self.detailImageHeightConstraint.isActive = false
                let heightConstraint = NSLayoutConstraint(item: self.choreImageImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0.000001, constant: 100)
                heightConstraint.isActive = true
            }
            
            if let choreDueString = chorePastDue {
                if choreDueString == "yes"{
                    
                    self.completedBtn.isEnabled = false
                    self.completedBtn.setTitle("Past Due: Cannot Complete", for: UIControlState.normal)
                    self.completedBtn.backgroundColor = UIColor.red
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
                    self.getChildren()
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
            
            for key in Array(dictUsers.keys) {
                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                self.children = self.children.filter({$0.parentid == self.parentID})
                self.children = self.children.filter({$0.userparent == false})
                
            }
        }
        
        
    }
    
    func isUserParent() {
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Bool {
                self.isActiveUserParent = val
            }
            
            //disables edit chore if user is a child
            self.editUIButton.isEnabled = self.isActiveUserParent
        }
    }
    
    func addCoins () {
        let databaseRef = Database.database().reference()
        
        var bonusOn = false
        var multiplier: Double = 1
        
        if let pid = parentID {
            databaseRef.child("app_settings/\(pid)").observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let isBonus = value?["bonus_toggled"] as? Bool
                if let unwrappedIsBonus = isBonus {
                    bonusOn = unwrappedIsBonus
                }
                
                let multiply = value?["multiplier_value"] as? Double
                if let mValue = multiply {
                    
                    multiplier = mValue
                }
                
                if bonusOn {
                    
                    var choreCoinVal: Double = Double(self.choreCoinValue)
                    
                    choreCoinVal *= multiplier
                    
                    self.choreCoinValue = Int(choreCoinVal)
                }
                
                self.coinValue += self.choreCoinValue
                
                if let uid = Auth.auth().currentUser?.uid{
                    databaseRef.child("running_total").child(uid).updateChildValues(["coin_total": self.coinValue])
                }
                
                self.performSegue(withIdentifier: "takePictureSegue", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "takePictureSegue" {
            if let takePictureVC = segue.destination as? TakePictureViewController{
                takePictureVC.choreId = choreId!
            }
        }
        
        if segue.identifier == "editChoreSegue"{
            if let editChoreVC = segue.destination as? ChoreEditViewController {
                if let id = choreId{
                    editChoreVC.choreId = id
                }
            }
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func markComplete(_ sender: UIButton) {
        addCoins()
    }
    
    @IBAction func editChoreBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "editChoreSegue", sender: nil)
    }
}
