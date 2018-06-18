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
    
    var coinValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = Auth.auth().currentUser?.displayName{
            usernameLabel.text = username
            coinAmtLabel.text = "\(coinValue)"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeChorePicture(_ sender: UIButton) {
    }

    @IBAction func saveChore(_ sender: UIButton) {
    }
}
