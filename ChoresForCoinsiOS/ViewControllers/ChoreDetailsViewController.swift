//
//  ChoreDetailsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ChoreDetailsViewController: UIViewController {
    
    @IBOutlet weak var choreNameLabel: UILabel!
    @IBOutlet weak var choreImageImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var choreValueLabel: UILabel!
    @IBOutlet weak var choreNoteTextView: UITextView!
    
    
    @IBOutlet weak var completedBtn: UIButton!
    
    @IBOutlet weak var headerUserNameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    
    var coinValue: Int = 0
    var choreCoinValue: Int = 0
    
    var choreId: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let username = Auth.auth().currentUser?.displayName{
            headerUserNameLabel.text = username
            getRunningTotal()
            getChoreData()
        }
        completedBtn.isEnabled = true
    }
    
    func getRunningTotal(){
        
        let databaseRef = Database.database().reference()
        
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("running_total").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                let value = snapshot.value as? NSDictionary
                
                let coin = value?["coin_total"] as? Int
                if let unwrappedCoin = coin{
                    self.coinValue = unwrappedCoin
                    self.coinAmtLabel.text = "\(unwrappedCoin)"
                } else {
                    self.coinAmtLabel.text = "0"
                }
            }
        }
    }
    
    
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
            let imageLocale = value?["chore_picture"] as? String
            let chorComplete = value?["chore_completed"] as? Bool
            
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
                self.choreCoinValue = Int(choreValue)!
                self.choreValueLabel.text = choreValue
            }
            
            self.usernameLabel.text = ""
            
            if let choreComplete = chorComplete {
                if choreComplete {
                    self.completedBtn.isEnabled = false
                    self.completedBtn.setTitle("Chore Completed", for: UIControlState.normal)
                }
            }
            
            
        }
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func markComplete(_ sender: UIButton) {
        
        let ref = Database.database().reference().child("chores")
        
        ref.child("\(choreId!)").updateChildValues(["chore_completed" : true])
        addCoins()
        dismiss(animated: true, completion: nil)
    }
    
    func addCoins (){
    
        let databaseRef = Database.database().reference()
    
        var bonusOn = false
        var multiplier: Double = 1
        databaseRef.child("app_settings").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let isBonus = value?["bonus_toggled"] as? Bool
            if let unwrappedIsBonus = isBonus {
                bonusOn = unwrappedIsBonus
            }
            
            let multiply = value?["multiplier_value"] as? Double
            if let mValue = multiply {
           
                multiplier = mValue
            }
        }
        if bonusOn {
            var choreCoinVal: Double = Double(choreCoinValue)
            
            choreCoinVal *= multiplier
            
            choreCoinValue = Int(choreCoinVal)
        }
        coinValue += choreCoinValue
        if let uid = Auth.auth().currentUser?.uid{
            databaseRef.child("running_total").child(uid).updateChildValues(["coin_total": self.coinValue])
        }
        
        
    }
    
}
