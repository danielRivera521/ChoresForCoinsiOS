//
//  SettingsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var coinValueTextField: UITextField!
    @IBOutlet weak var bonusDaySwitch: UISwitch!
    @IBOutlet weak var multiplierValueTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var childRedeemView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var redDot: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var coinValView: UIView!
    @IBOutlet weak var bonusDayView: UIView!
    @IBOutlet weak var BonusMultView: UIView!
    @IBOutlet weak var coinValHeight: NSLayoutConstraint!
    @IBOutlet weak var coinValHeightiPad: NSLayoutConstraint!
    
    var isFirstLoad = true
    var coinValue = 0
    var runningTotal = 0
    var parentID: String?
    var userID: String?
    var isParent = true
    var isActiveUserParent = false
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    
    var coinConversion: Double = 1    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        coinValueTextField.delegate = self
        multiplierValueTextField.delegate = self
        
        // bonus toggle off by default
        bonusDaySwitch.isOn = false
        
        childRedeemView.isHidden = true
        
        if (Auth.auth().currentUser?.displayName) != nil{
            displayHeaderName()
        }
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        // show the correct background image based on user selection
        getBackground()
        
        //gets the custom parent id created in the registration
        getParentId()
        
        // get photo for profile button
        getPhoto()
        
        checkIfParent()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isUserParent()
        getPhoto()
        // get app settings from database and fill out text fields and toggle button accordingly
        getAppSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // when view is going to disappear, check and save the setting values
    override func viewWillDisappear(_ animated: Bool) {
        // use parent id as key for each app setting object. This way all users with that parent id will have the save app settings... backgrounds are an individual setting
        if let pid = parentID {
            // get database object for app settings
            let ref = Database.database().reference().child("app_settings/\(pid)")
            
            var coinValue = 1
            var multValue: Double = 1
            
            // unwrap coin value and convert to int
            if !(coinValueTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                if let coinValUnwrapped = coinValueTextField.text {
                    if let coinvalint = Int(coinValUnwrapped) {
                        coinValue = coinvalint
                    }
                }
            }
            
            // unwrap bonus value and convert to int
            if !(multiplierValueTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                if let multValueUnwrapped = multiplierValueTextField.text {
                    if let multvalint = Double(multValueUnwrapped) {
                        multValue = multvalint
                    }
                }
            }
            
            // save coin value
            ref.child("coin_dollar_value").setValue(coinValue)
            // save bonus day toggle
            ref.child("bonus_toggled").setValue(bonusDaySwitch.isOn)
            //bonus coin value
            ref.child("multiplier_value").setValue(multValue)
            
            print("Message from Settings View: mult = \(multValue)")
        }
    }
    
    
    // MARK: Custom Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss keyboard when user touches outside of keyboard
        self.view.endEditing(true)
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
    
    //gets the parent generated id from the user's node in the database
    func getParentId(){
        if let actualUID = userID{
            _ = Database.database().reference().child("user").child(actualUID).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let id = value?["parent_id"] as? String
                if let actualID = id{
                    self.parentID = actualID
                    
                    // get app settings from database and fill out text fields and toggle button accordingly
                    self.getAppSettings()
                }
            }
        }
        
    }
    
    func isUserParent(){
        
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Bool {
                self.isActiveUserParent = val
                
                if self.isActiveUserParent {
                    self.getRunningTotalParent()
                } else {
                    self.getRunningTotal()
                }
            }
        }
    }
    
    func getRunningTotal(){
        
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("running_total").child(uid).child("coin_total").observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                self.coinValue = snapshot.value as? Int ?? 0
                self.coinAmtLabel.text = "\(self.coinValue)"
            }
        }
        
    }
    
    func getRunningTotalParent(){
        getChildren()
        getCoinTotals()
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
            
            self.checkRedeem(children: self.children)
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
    
    func getPhoto() {
        
        let DatabaseRef = Database.database().reference()
        if let uid = userID{
            DatabaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                //gets the image URL from the user database
                if let profileURL = value?["profile_image_url"] as? String{
                
                    let url = URL(string: profileURL)
                    ImageService.getImage(withURL: url!, completion: { (image) in
                        
                        self.profileButton.setBackgroundImage(image, for: .normal)
                    })
              //      self.profileButton.loadImagesUsingCacheWithUrlString(urlString: profileURL, inViewController: self)
                    //turn button into a circle
                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                    self.profileButton.layer.masksToBounds = true
                }
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
    
    func checkRedeem(children: [ChildUser]) {
        self.redDot.isHidden = true
        for child in children {
            if let childuid = child.userid {
                Database.database().reference().child("user/\(childuid)/isRedeem").observeSingleEvent(of: .value) { (snapshot) in
                    if let isRedeem = snapshot.value as? Bool {
                        if isRedeem && self.isActiveUserParent {
                            self.redDot.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    func getBackground() {
        if let uid = self.userID {
            
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
    
    func getAppSettings() {
        if let pid = parentID {
            // get database object for app settings
            let ref = Database.database().reference().child("app_settings/\(pid)")
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let appSettings = snapshot.value as? NSDictionary {
                    if let coinval = appSettings["coin_dollar_value"] as? Int {
                        self.coinValueTextField.text = "\(coinval)"
                    }
                    
                    if let bonusToggle = appSettings["bonus_toggled"] as? Bool {
                        self.bonusDaySwitch.isOn = bonusToggle
                    }
                    
                    if let multVal = appSettings["multiplier_value"] as? Double {
                        self.multiplierValueTextField.text = "\(multVal)"
                    }
                }
            }
        }
    }
    
    func checkIfParent() {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if !isParent {
                    self.coinValView.isHidden = true
                    self.bonusDayView.isHidden = true
                    self.BonusMultView.isHidden = true
                    
                }
            }
        })
    }
    
    
    // MARK: Actions
    
    @IBAction func toggleBonusDay(_ sender: UISwitch) {
    }
    
    @IBAction func selectBackground(_ sender: UIButton) {
        if let uid = userID {
            var bgSelection = 0
            
            // switch to determine which button was selected via tag
            switch sender.tag {
            case 1:
                bgSelection = 0
                self.bgImage.image = #imageLiteral(resourceName: "whiteBG")
            case 2:
                bgSelection = 1
                self.bgImage.image = #imageLiteral(resourceName: "orangeBG")
            case 3:
                bgSelection = 2
                self.bgImage.image = #imageLiteral(resourceName: "greenBG")
            case 4:
                bgSelection = 3
                self.bgImage.image = #imageLiteral(resourceName: "redBG")
            case 5:
                bgSelection = 4
                self.bgImage.image = #imageLiteral(resourceName: "purpleBG")
            default:
                bgSelection = 0
                self.bgImage.image = #imageLiteral(resourceName: "whiteBG")
            }
            
            Database.database().reference().child("user/\(uid)/bg_image").setValue(bgSelection)
        }
    }
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.performSegue(withIdentifier: "toCoinFromSettings", sender: nil)
                } else {
                    self.childRedeemView.isHidden = false
                }
            }
        })
    }
    
    @IBAction func childRedeem(_ sender: UIButton) {
        if coinValue <= 0 {
            AlertController.showAlert(self, title: "Cannot Redeem", message: "YOu do not have any coins to redeem. Try completing some chores to get some coins")
        } else {
            getConversionRate()
            let convertedValue = coinConversion * Double(coinValue)
            let dollarValueString = String(format: "$%.02f", convertedValue)
            
            let alert = UIAlertController(title: "Coin Redemption Requested", message: "You are currently requesting to have your coins redeemed. At the current rate you will receive \(dollarValueString) for the coins you have acquired.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                if let uid = self.userID {
                    Database.database().reference().child("user/\(uid)/isRedeem").setValue(true)
                    
                    self.childRedeemView.isHidden = true
                    
                    AlertController.showAlert(self, title: "Redeemed", message: "Your coin redeem has been requested. We'll let your parent know!")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.childRedeemView.isHidden = true
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
        }

    }
    
}
