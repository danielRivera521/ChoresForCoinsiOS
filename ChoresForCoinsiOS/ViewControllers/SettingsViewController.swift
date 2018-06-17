//
//  SettingsViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class SettingsViewController: ViewController {

    @IBOutlet weak var coinValueTextField: UITextField!
    @IBOutlet weak var bonusDaySwitch: UISwitch!
    @IBOutlet weak var multiplierValueTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func toggleBonusDay(_ sender: UISwitch) {
    }

    @IBAction func selectBackground(_ sender: UIButton) {
        // switch to determine which button was selected via tag
        switch sender.tag {
        case 1:
            print() // can delete this. it's just a placeholder
        case 2:
            print() // can delete this. it's just a placeholder
        case 3:
            print() // can delete this. it's just a placeholder
        case 4:
            print() // can delete this. it's just a placeholder
        case 5:
            print() // can delete this. it's just a placeholder
        default:
            break
        }
    }
}
