//
//  ForgotPasswordEnterCodeViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class ForgotPasswordEnterCodeViewController: UIViewController {

    @IBOutlet weak var codeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toOverview(_ sender: UIButton) {
        // dismiss back to tab bar controller
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}
