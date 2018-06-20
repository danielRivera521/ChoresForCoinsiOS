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
    
    
    
    @IBOutlet weak var headerUserNameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    
    var coinValue: Int?
    
    var choreId: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let username = Auth.auth().currentUser?.displayName{
            headerUserNameLabel.text = username
            getRunningTotal()
            getChoreData()
        }
    }
    
    func getRunningTotal(){
        
        let databaseRef = Database.database().reference()
        
        
        if let uid = Auth.auth().currentUser?.uid {
            
            
            databaseRef.child("running_total").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                if snapshot.exists(){
                    
                    let value = snapshot.value as? NSDictionary
                    let childID = value?["child_id"] as? String
                    if let actualID = childID {
                        if uid == actualID {
                            let coinValueAmt = value?["coin_total"] as? Int
                            if let actualCoinVal = coinValueAmt{
                                self.coinAmtLabel.text = "\(actualCoinVal)"
                            } else {
                                self.coinAmtLabel.text = "0"
                            }
                        } else {
                            self.coinAmtLabel.text = "0"
                        }
                    }
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
                self.choreValueLabel.text = choreValue
            }
            
            self.usernameLabel.text = ""
            
            
        }
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func markComplete(_ sender: UIButton) {
        
        let ref = Database.database().reference().child("chores")
        
        ref.child("\(choreId!)").updateChildValues(["chore_completed" : true])
        dismiss(animated: true, completion: nil)
        
        
    }

    
}
