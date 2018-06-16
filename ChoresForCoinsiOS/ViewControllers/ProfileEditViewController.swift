//
//  ProfileEditViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class ProfileEditViewController: ViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var parentKeyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: UIButton) {
        // dismiss back to tab bar controller
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}
