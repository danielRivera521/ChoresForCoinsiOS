//
//  ChoreDetailsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class ChoreDetailsViewController: UIViewController {
    
    @IBOutlet weak var choreNameLabel: UILabel!
    @IBOutlet weak var choreImageImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var choreValueLabel: UILabel!
    @IBOutlet weak var choreNoteTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func markComplete(_ sender: UIButton) {
    }
    
}
