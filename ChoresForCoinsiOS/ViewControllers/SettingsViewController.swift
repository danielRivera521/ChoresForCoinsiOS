//
//  SettingsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var coinValueTextField: UITextField!
    @IBOutlet weak var bonusDaySwitch: UISwitch!
    @IBOutlet weak var multiplierValueTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var childRedeemView: UIView!
    
    var isFirstLoad = true
    var coinValue = 0
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var runningTotal = 0
    var parentID: String?
    var userID: String?
    var isParent = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        childRedeemView.isHidden = true
        
        if let username = Auth.auth().currentUser?.displayName{
            usernameLabel.text = username
        }
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //gets the custom parent id created in the registration
        getParentId()
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "whiteBG"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRunningTotal()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func toggleBonusDay(_ sender: UISwitch) {
    }
    
    @IBAction func selectBackground(_ sender: UIButton) {
        // switch to determine which button was selected via tag
        switch sender.tag {
        case 1:
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "whiteBG.png")!)
        case 2:
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "orangeBG.png")!)
        case 3:
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "greenBG.png")!)
        case 4:
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "redBG.png")!)
        case 5:
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "purpleBG.png")!)
        default:
            break
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
        // zero out coin total and update db
        
        childRedeemView.isHidden = true
    }
    
}
