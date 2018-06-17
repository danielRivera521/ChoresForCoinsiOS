//
//  SignUpParentChildViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class SignUpParentChildViewController: UIViewController {

    //create a bool to see if the user is a parent or not. To be used in a segue to create account view controller
    var isParent: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func parentRegistrationBtn(_ sender: UIButton) {
        
        isParent = true
    }
    
    @IBAction func childRegistrationBtn(_ sender: UIButton) {
        isParent = false
    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createParentSegue" {
            isParent = true
        }
        if segue.identifier == "createChildSegue" {
            isParent = false
        }
        
        if let createAccountVC = segue.destination as? CreateAccountViewController{
            
            createAccountVC.isParent = isParent
            
        }
        
    }
    
}
