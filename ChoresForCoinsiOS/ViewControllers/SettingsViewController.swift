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
    
    var isFirstLoad = true
    var coinValue = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let username = Auth.auth().currentUser?.displayName{
            usernameLabel.text = username
            getRunningTotal()
        }
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "whiteBG"))
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
        
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("running_total").child(uid).child("coin_total").observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                self.coinValue = snapshot.value as? Int ?? 0
                self.coinAmtLabel.text = "\(self.coinValue)"
            }
        }
    }
    
}
