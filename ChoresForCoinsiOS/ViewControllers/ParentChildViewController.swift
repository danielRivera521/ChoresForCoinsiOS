//
//  ParentChildViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/18/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class ParentChildViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createParentOrChild(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            // Handle Parent
            
            performSegue(withIdentifier: "goToOverViewFromPC", sender: self)
        case 2:
            // Handle Child
            
            performSegue(withIdentifier: "goToOverViewFromPC", sender: self)
        default:
            break
        }
    }
    
}
