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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get username and set it to label in header
        checkDatabase()
        
        // get coinvalue from db and set it to label
        getRunningTotal()
        
        // disable all buttons except for gray plus and minus
        // they will enable when plus or minus is tapped
        numButtons = [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9, btnDelete]
        if let numButtons = numButtons {
            for button in numButtons {
                button.isEnabled = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if let coinValue = coinValue {
            var newCoinValue = coinValue
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
                                    if let username = Auth.auth().currentUser?.displayName{
                                        self.getRunningTotal()
                                        self.usernameLabel.text = username
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
    
    func getRunningTotal(){
        
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("running_total").child(uid).child("coin_total").observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                self.coinValue = snapshot.value as? Int ?? 0
                self.coinTotalLabel.text = "\(self.coinValue!)"
                self.coinAmtLabel.text = "\(self.coinValue!)"
            }
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
        
        // dismiss view
        dismiss(animated: true, completion: nil)
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
        // remove last character
        if numString.count > 1 {
            numString.remove(at: numString.endIndex)
        } else {
            numString = "0"
        }
        
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
        
        if let uid = Auth.auth().currentUser?.uid{
            databaseRef.child("running_total").child(uid).updateChildValues(["coin_total": self.coinValue])
        }
        
        
    }
}
