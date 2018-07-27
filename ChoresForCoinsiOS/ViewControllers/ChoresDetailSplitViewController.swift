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

protocol ChoreEditDelegate: class {
    func choreEdit(_ choreID: String)
}

class ChoresDetailSplitViewController: UIViewController {
    
    // MARK: - Outlets
    
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
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var editContainerView: UIView!
    @IBOutlet weak var emptyBGCover: UIImageView!
    @IBOutlet weak var selectChoreLabel: UILabel!
    
    
    // MARK: - Properties
    
    weak var delegate: ChoreEditDelegate?
    
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
    
    var coinConversion: Double = 1
    
    private var imagePicker: UIImagePickerController!
    
    
    // MARK: - ViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        editContainerView.isHidden = true
        
        // this is here so the app doesn't crash on first run. choreId gets set at a differnt time in the app.
        choreId = "NotCorrect"
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        getChoreData()
        
        completedBtn.isEnabled = true
        
        //gets the custom parent id created in the registration
        getParentId()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isUserParent()
        getBackground()
        emptyBGCover.isHidden = true
        if let unwrappedChoreId = choreId{
            if unwrappedChoreId == "NotCorrect"{
                emptyBGCover.isHidden = false
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        editContainerView.isHidden = true
    }
    
    // MARK: - Custom Methods
    
    func getChoreData(){
        
        emptyBGCover.isHidden = true
        
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
            let completedName = value?["chore_username"] as? String
            
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
            if let completedChoreName = completedName {
                self.usernameLabel.text = completedChoreName
            } else {
                if let userNameString = choreUserName{
                    self.usernameLabel.text = userNameString
                } else {
                    self.usernameLabel.text = ""
                }
            }
            
            if let choreComplete = chorComplete {
                if choreComplete {
                    self.completedBtn.isEnabled = false
                    self.completedBtn.setTitle("Chore Completed", for: UIControlState.normal)
                }
            }
            
            if let choreImageURL = imageLocale {
                print(choreImageURL)
                self.choreImageImageView.loadImagesUsingCacheWithUrlString(urlString: choreImageURL, inViewController: self)
            } else {
//                if self.detailImageHeightConstraint != nil {
//                    self.detailImageHeightConstraint.isActive = false
//                    let heightConstraint = NSLayoutConstraint(item: self.choreImageImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0.000001, constant: 100)
//                    heightConstraint.isActive = true
//                }
                
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
        getCoinTotal()
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
    
    func getCoinTotal(){
        
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            databaseRef.child("running_total").child(uid).child("coin_total").observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                self.coinValue = snapshot.value as? Int ?? 0
                
            }
        }
        
        
    }
    func getConversionRate(){
        if let unwrappedParentID = parentID{
            
            Database.database().reference().child("app_settings").child(unwrappedParentID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                if let conversionValue = value?["coin_dollar_value"] as? Double{
                    
                    self.coinConversion = conversionValue
                }
                
            })
        }
        
    }
    
    func getBackground() {
        if UIDevice.current.orientation == .portrait {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "takePictureSegue" {
            if let takePictureVC = segue.destination as? TakePictureViewController{
                takePictureVC.choreId = choreId!
            }
        }
        
        if segue.identifier == "editEmbedSegue" {
            if let destination = segue.destination as? ChoreEditViewController {
                self.delegate = destination
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func markComplete(_ sender: UIButton) {
        
        //ensure that the completion button was not pressed accidentally.
        let completeAlert = UIAlertController(title: "Complete Chore", message: "Are you ready to complete the chore? If so click ok to complete the chore and add a picture.", preferredStyle: .alert)
       //processes the ok action and marks teh chore complete and send the user to the takepicture view controller.
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.addCoins()
            self.performSegue(withIdentifier: "takePictureSegue", sender: nil)
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        completeAlert.addAction(okAction)
        completeAlert.addAction(cancelAction)
        
        present(completeAlert, animated: true, completion: nil)
    }
    
    @IBAction func editChoreBtn(_ sender: UIButton) {
        if let choreID = choreId {
            editContainerView.isHidden = false
            
            emptyBGCover.isHidden = false
            
            delegate?.choreEdit(choreID)
        }
    }
    
    @IBAction func unwindToDetails(segue:UIStoryboardSegue) {
        editContainerView.isHidden = true
        
        choreImageImageView.image = #imageLiteral(resourceName: "placeholderImg")
        
        if segue.source is ChoreEditViewController {
            if let senderVC = segue.source as? ChoreEditViewController {
                if senderVC.didDelete {
                    emptyBGCover.isHidden = false
                    selectChoreLabel.isHidden = false
                    choreNameLabel.text = "Chore Name"
                    usernameLabel.text = ""
                    startDateLabel.text = "MM/DD/YYYY"
                    dueDateLabel.text = "MM/DD/YYYY"
                    choreValueLabel.text = "0"
                    completedBtn.isEnabled = false
                } else {
                    //gets the firebase generated id
                    userID = (Auth.auth().currentUser?.uid)!
                    choreId = senderVC.choreId
                    getChoreData()
                    
                    //gets the custom parent id created in the registration
                    getParentId()
                }
            }
        }
    }
}

extension ChoresDetailSplitViewController:
ChoreSelectionDelegate {
    func choreSelected(_ choreID: String) {
        
        choreId = choreID
        
        emptyBGCover.isHidden = true
        selectChoreLabel.isHidden = true
        
        choreImageImageView.image = #imageLiteral(resourceName: "placeholderImg")
        
        completedBtn.isEnabled = true
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        getChoreData()
        
        //gets the custom parent id created in the registration
        getParentId()
    }
}







