//
//  ChoreDetailsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

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

    var coinValue = 0
    
    var choreId: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let username = Auth.auth().currentUser?.displayName{
            headerUserNameLabel.text = username
            getRunningTotal()
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
    
    
    func getChoreData(){
        
        let ref = Database.database().reference()
        
        ref.child("chores").child(choreId).observeSingleEvent(of: .value) { (snapshot) in
         
            let choreName: String? = snapshot.value(forKey: "chore_name") as? String
            let choreDescript: String? = snapshot.value(forKey: "chore_description") as? String
            let startChore: String? = snapshot.value(forKey: "date_start") as? String
            let choreDue: String? = snapshot.value(forKey: "date_due") as? String
            let choreValue: Int? = snapshot.value(forKey: "number_coins") as? Int
            let note: String? = snapshot.value(forKey: "chore_note") as? String
            let imageLocation: String? = snapshot.value(forKey: "chore_picture") as? String
            
            if choreName != nil  {
                self.choreNameLabel.text = choreName!

            }
            if choreDescript != nil {
                self.choreDescriptionTextView.text = choreDescript!
            }
            if  startChore != nil {
                self.startDateLabel.text = startChore!
            }
            if choreDue != nil {
                self.dueDateLabel.text = choreDue!
            }
            if note != nil {
                self.choreNoteTextView.text = note!
                
            }
            
            if choreValue != nil{
                self.choreValueLabel.text = "\(choreValue!)"
            }
        
        }
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func markComplete(_ sender: UIButton) {
    }
    
}
