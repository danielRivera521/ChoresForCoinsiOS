//
//  AddRemoveCoinsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class AddRemoveCoinsViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var coinTotalLabel: UILabel!
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    @IBOutlet weak var btn8: UIButton!
    @IBOutlet weak var btn9: UIButton!
    @IBOutlet weak var btnGrayMinus: UIButton!
    @IBOutlet weak var btnGrayAdd: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    var ref: DatabaseReference?
    var coinValue: Int?
    var numButtons: [UIButton]?
    var isAdd = false
    var numString: String = ""
    var idFound = false
    var childId: String?
    var userID: String?
    var parentID: String?
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var runningTotal = 0
    var isParent = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get username and set it to label in header
        checkDatabase()
        
        // get coinvalue from db and set it to label
        //getRunningTotal()
        
        if let coinvalue = coinValue {
            coinTotalLabel.text = String(coinvalue)
            coinValue = coinvalue
        }
        
        // disable all buttons except for gray plus and minus
        // they will enable when plus or minus is tapped
        numButtons = [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9, btnDelete]
        if let numButtons = numButtons {
            for button in numButtons {
                button.isEnabled = false
            }
        }
        
        //edit header information
        let name = Auth.auth().currentUser?.displayName
        if name != nil {
            displayHeaderName()
            //getRunningTotal()
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        getRunningTotalParent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func removeOneCoin(_ sender: UIButton) {
        if let coinValue = coinValue {
            var newCoinValue = coinValue
            // subtract 1 from coin value, unles value is 0
            if newCoinValue > 0 {
                newCoinValue -= 1
                self.coinValue = newCoinValue
                coinTotalLabel.text = "\(self.coinValue!)"
            }
        }
    }
    
    @IBAction func addOneCoin(_ sender: UIButton) {
        if let coinvalue = coinValue {
            var newCoinValue = coinvalue
            // add 1 to coin value
            newCoinValue += 1
            self.coinValue = newCoinValue
            coinTotalLabel.text = "\(self.coinValue!)"
        }
    }
    
    @IBAction func calcButtons(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            numString = "\(numString)0"
            coinTotalLabel.text = "\(numString)"
        case 1:
            numString = "\(numString)1"
            coinTotalLabel.text = "\(numString)"
        case 2:
            numString = "\(numString)2"
            coinTotalLabel.text = "\(numString)"
        case 3:
            numString = "\(numString)3"
            coinTotalLabel.text = "\(numString)"
        case 4:
            numString = "\(numString)4"
            coinTotalLabel.text = "\(numString)"
        case 5:
            numString = "\(numString)5"
            coinTotalLabel.text = "\(numString)"
        case 6:
            numString = "\(numString)6"
            coinTotalLabel.text = "\(numString)"
        case 7:
            numString = "\(numString)7"
            coinTotalLabel.text = "\(numString)"
        case 8:
            numString = "\(numString)8"
            coinTotalLabel.text = "\(numString)"
        case 9:
            numString = "\(numString)9"
            coinTotalLabel.text = "\(numString)"
        case 10:
            if let numButtons = numButtons {
                for button in numButtons {
                    button.isEnabled = true
                }
                btnGrayMinus.isEnabled = false
                btnGrayAdd.isEnabled = false
                btnDelete.isEnabled = true
                
                isAdd = false
            }
            break
        case 11:
            if let numButtons = numButtons {
                for button in numButtons {
                    button.isEnabled = true
                }
                btnGrayMinus.isEnabled = false
                btnGrayAdd.isEnabled = false
                btnDelete.isEnabled = true
                
                isAdd = true
            }
            break
        default:
            break
        }
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
    
    func calculateNewTotal () {
        // convert numString to Int
        let numStringInt = Int(numString)
        
        if isAdd {
            if let coinTotal = coinValue {
                var coinTotalNew = coinTotal
                
                if let numStringInt = numStringInt {
                    coinTotalNew += numStringInt
                    self.coinValue = coinTotalNew
                    coinTotalLabel.text = "\(self.coinValue!)"
                }
            }
        } else {
            if let coinTotal = coinValue {
                var coinTotalNew = coinTotal
                
                if let numStringInt = numStringInt {
                    coinTotalNew -= numStringInt
                    
                    if coinTotalNew < 0 {
                        coinTotalNew = 0
                    }
                    
                    self.coinValue = coinTotalNew
                    coinTotalLabel.text = "\(self.coinValue!)"
                }
            }
        }
        
        numString = ""
    }
    
    @IBAction func done(_ sender: UIButton) {
        // update database with new coin total
        updateTotalCoins()
        // update coin total in header
        self.coinAmtLabel.text = "\(self.coinValue!)"
    }
    
    @IBAction func redeemCoins(_ sender: UIButton) {
        if let numButtons = numButtons {
            for button in numButtons {
                button.isEnabled = false
            }
            btnGrayMinus.isEnabled = true
            btnGrayAdd.isEnabled = true
            btnDelete.isEnabled = false
            
            coinValue = 0
            coinTotalLabel.text = "\(self.coinValue!)"
            
            // update new coin value on database
            updateTotalCoins()
            // dismiss view
        }
    }
    
    @IBAction func deleteNumbers(_ sender: UIButton) {
//        // remove last character
//        if numString.count > 1 {
//            numString.remove(at: numString.endIndex)
//        } else {
//            numString = "0"
//        }
        
        numString = "0"
        
        // update string in view
        coinTotalLabel.text = numString
    }
    
    
    @IBAction func calculate(_ sender: UIButton) {
        if let numButtons = numButtons {
            for button in numButtons {
                button.isEnabled = false
            }
            btnGrayMinus.isEnabled = true
            btnGrayAdd.isEnabled = true
            btnDelete.isEnabled = false
            
            calculateNewTotal()
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
        }
        
        
    }
    
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
