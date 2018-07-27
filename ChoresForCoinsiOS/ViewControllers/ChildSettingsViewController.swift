//
//  ChildSettingsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 7/25/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class ChildSettingsViewController: UIViewController {
    
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
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //gets the custom parent id created in the registration
        getParentId()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isUserParent()
        getBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // when view is going to disappear, check and save the setting values
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    // MARK: Custom Functions
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
