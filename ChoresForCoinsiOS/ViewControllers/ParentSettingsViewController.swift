//
//  ParentSettingsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 7/25/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class ParentSettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var coinValueTextField: UITextField!
    @IBOutlet weak var bonusDaySwitch: UISwitch!
    @IBOutlet weak var multiplierValueTextField: UITextField!
    @IBOutlet weak var bgImage: UIImageView!
    
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
    var animRedeemView: UIImageView?
    var animRedeemAlertContainer = [UIImage] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        coinValueTextField.delegate = self
        multiplierValueTextField.delegate = self
        
        // bonus toggle off by default
        bonusDaySwitch.isOn = false
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //gets the custom parent id created in the registration
        getParentId()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isUserParent()
        // get app settings from database and fill out text fields and toggle button accordingly
        getAppSettings()
        getBackground()
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
}
