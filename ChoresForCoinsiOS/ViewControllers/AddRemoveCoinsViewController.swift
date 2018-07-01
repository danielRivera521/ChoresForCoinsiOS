//
//  AddRemoveCoinsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class AddRemoveCoinsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var childNameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var coinTotalTextField: UITextField!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var redDotCoin: UIImageView!
    @IBOutlet weak var redDotRedeem: UIImageView!
    
    
    // MARK: Properties
    
    var ref: DatabaseReference?
    var coinValue: Int?
    var numButtons: [UIButton]?
    var numString: String = ""
    var idFound = false
    var childId: String?
    var childName: String?
    var userID: String?
    var parentID: String?
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var runningTotal = 0
    var isParent = true
    var firstRun = true
    var isRedeem = false
    
    
    // MARK: View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set child name label
        if let childName = childName {
            childNameLabel.text = childName
        }
        
        if isRedeem {
            redDotCoin.isHidden = false
            redDotRedeem.isHidden = false
        }
        
        // get username and set it to label in header
        checkDatabase()
        
        // get coinvalue from db and set it to label
        //getRunningTotal()
        
        if let coinvalue = coinValue {
            coinTotalTextField.text = String(coinvalue)
            coinValue = coinvalue
        }
        
        if let uid = Auth.auth().currentUser?.uid {
            userID = uid
        }
        
        //edit header information
        let name = Auth.auth().currentUser?.displayName
        if name != nil {
            displayHeaderName()
        }
        
        getParentId()
        
        // gets all children with same parent id as user
        getChildren()
        
        // gets coin totals for all children
        getCoinTotals()
        
        // get photo for profile button
        getPhoto()
        
        // makes it so tapping anywhere will dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        getRunningTotalParent()
//        getPhoto()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ref?.removeAllObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Custom functions
    
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
    
    func getRunningTotalParent(){
        
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
            
            for key in Array(dictUsers.keys) {
                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                self.children = self.children.filter({$0.parentid == self.parentID})
                self.children = self.children.filter({$0.userparent == false})
                
            }
        }
        
        
    }
    
    func getCoinTotals() {
        coinTotals.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictRunningTotal = dictRoot["running_total"] as? [String:AnyObject] ?? [:]
            
            for key in Array(dictRunningTotal.keys) {
                for child in self.children {
                    if key == child.userid {
                        self.coinTotals.append(RunningTotal(dictionary: (dictRunningTotal[key] as? [String:AnyObject])!, key: key))
                    }
                }
            }
            
            var sumTotal = 0
            
            for coinTotal in self.coinTotals {
                for child in self.children {
                    if coinTotal.key == child.userid {
                        if let total = coinTotal.cointotal {
                            sumTotal += total
                        }
                    }
                }
            }
            
            self.coinAmtLabel.text = String(sumTotal)
        }
    }
    
    func checkDatabase() {
        
        //let databaseRef = Database.database().reference().child("user")
        
        if let uid = Auth.auth().currentUser?.uid {
            
            ref?.child("user").observe(.value) { (snapshot) in
                
                if snapshot.exists(){
                    if let userIdDictionary = snapshot.value as? NSDictionary{
                        for id in userIdDictionary.keyEnumerator(){
                            if let userID = id as? String{
                                if userID == uid {
                                    // user is in database
                                    self.idFound = true
                                    if (Auth.auth().currentUser?.displayName) != nil{
                                        //self.getRunningTotal()
                                        self.displayHeaderName()
                                        return
                                    }
                                    
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
    
    func updateTotalCoins (){
        
        let databaseRef = Database.database().reference()
        
        var coinValue = 0
        
        if let coinvalue = self.coinValue {
            coinValue = coinvalue
        }
        
        if let uid = childId {
            databaseRef.child("running_total").child(uid).updateChildValues(["coin_total": coinValue])
            databaseRef.child("running_total").child(uid).updateChildValues(["isRedeem": false])
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        coinTotalTextField.text = ""
    }
    
    
    // MARK: Actions
    
    @IBAction func removeOneCoin(_ sender: UIButton) {
        if let coinValue = coinValue {
            var newCoinValue = coinValue
            // subtract 1 from coin value, unles value is 0
            if newCoinValue > 0 {
                newCoinValue -= 1
                self.coinValue = newCoinValue
                coinTotalTextField.text = "\(self.coinValue!)"
            }
        }
    }
    
    @IBAction func addOneCoin(_ sender: UIButton) {
        if let coinvalue = coinValue {
            var newCoinValue = coinvalue
            // add 1 to coin value
            newCoinValue += 1
            self.coinValue = newCoinValue
            coinTotalTextField.text = "\(self.coinValue!)"
        }
    }
    
    @IBAction func done(_ sender: UIButton) {
        if let newCoinValue = coinTotalTextField.text {
            if !newCoinValue.trimmingCharacters(in: .whitespaces).isEmpty {
                coinValue = Int(newCoinValue)
            } else {
                AlertController.showAlert(self, title: "Warning", message: "Please enter a coin value.")
                return
            }
        }
        
        // update database with new coin total
        updateTotalCoins()
        // update coin total in header
        self.coinAmtLabel.text = "\(self.coinValue!)"
        // dismiss view
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func redeemCoins(_ sender: UIButton) {
        coinValue = 0
        coinTotalTextField.text = "\(self.coinValue!)"
        
        if let uid = childId {
            Database.database().reference().child("user/\(uid)/isRedeem").setValue(false)
        }
        
        // update new coin value on database
        updateTotalCoins()
        
        // dismiss view
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Custom Class
    
    class RunningTotal {
        var key: String
        var userid: String?
        var cointotal: Int?
        
        init(dictionary: [String:AnyObject], key: String) {
            self.key = key
            if let userid = dictionary["user_id"] as? String {
                self.userid = userid
            }
            if let cointotal = dictionary["coin_total"] as? Int {
                self.cointotal = cointotal
            }
        }
    }
}
