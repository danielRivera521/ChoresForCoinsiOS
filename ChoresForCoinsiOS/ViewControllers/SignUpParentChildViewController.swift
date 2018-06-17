//
//  SignUpParentChildViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class SignUpParentChildViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doGoToCreateAccount(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            // Code for handling parent
            performSegue(withIdentifier: "createAccountSegue", sender: sender)
        case 2:
            // Code for handling child
            performSegue(withIdentifier: "createAccountSegue", sender: sender)
        default:
            break
        }
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
