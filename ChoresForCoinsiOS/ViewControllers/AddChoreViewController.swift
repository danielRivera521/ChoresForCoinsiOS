//
//  AddChoreViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class AddChoreViewController: UIViewController {
    
    @IBOutlet weak var choreImageUIButton: UIButton!
    @IBOutlet weak var choreNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!    
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var choreValueTextField: UITextField!
    @IBOutlet weak var choreNoteTextView: UITextView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    var isFirstLoad = true
    var coinValue = 0
    
    var ref: DatabaseReference?
    
    // create date picker
    let picker = UIDatePicker()
    // array to hold all users with same generatedId
    var family = [UserModel] ()
    var currentUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let username = Auth.auth().currentUser?.displayName{
            usernameLabel.text = username
            getRunningTotal()
            ref = Database.database().reference()
            
            // set up date pickers
            createDatePickerStart()
            createDatePickerDue()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeChorePicture(_ sender: UIButton) {
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
    func createDatePickerStart() {
        // create toolbar for done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedStart))
        toolbar.setItems([done], animated: false)
        
        startDateTextField.inputAccessoryView = toolbar
        startDateTextField.inputView = picker
        
        // format picker for date only
        picker.datePickerMode = .date
    }
    
    func createDatePickerDue() {
        // create toolbar for done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedDue))
        toolbar.setItems([done], animated: false)
        
        dueDateTextField.inputAccessoryView = toolbar
        dueDateTextField.inputView = picker
        
        // format picker for date only
        picker.datePickerMode = .date
    }
    
    @objc func donePressedStart() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: picker.date)
        
        startDateTextField.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    @objc func donePressedDue() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: picker.date)
        
        dueDateTextField.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    @IBAction func saveChore(_ sender: UIButton) {
        let newChoreRef = ref?.child("chores").childByAutoId()
        let currentChoreId = newChoreRef?.key
        if let currentChoreId = currentChoreId {
            ref?.child("chores/\(currentChoreId)/chore_name").setValue(choreNameTextField.text)
            ref?.child("chores/\(currentChoreId)/user_name").setValue(usernameTextField.text)
            ref?.child("chores/\(currentChoreId)/chore_description").setValue(choreDescriptionTextView.text)
            ref?.child("chores/\(currentChoreId)/start_date").setValue(startDateTextField.text)
            ref?.child("chores/\(currentChoreId)/due_date").setValue(dueDateTextField.text)
            ref?.child("chores/\(currentChoreId)/chore_note").setValue(choreNoteTextView.text)
            ref?.child("chores/\(currentChoreId)/number_coins").setValue(choreValueTextField.text)
            
            createAssignmentID(choreID: currentChoreId)
        }
        
        // TODO: Add alert that says the chore was saved
        
        // clear the text fields
        choreNameTextField.text = nil
        usernameTextField.text = nil
        choreDescriptionTextView.text = nil
        startDateTextField.text = nil
        dueDateTextField.text = nil
        choreValueTextField.text = nil
        choreNoteTextView.text = nil
        
    }
    //creates initial assignment
    func createAssignmentID(choreID: String){
        let newAssignRef = ref?.child("chore_assignment").childByAutoId()
        let assignID = newAssignRef?.key
        if let assignID = assignID {
            ref?.child("chores/\(assignID)/chore_id").setValue(choreID)
            ref?.child("chores/\(assignID)/chore_completed").setValue(false)
        }
        
    }
    
    
    
}
