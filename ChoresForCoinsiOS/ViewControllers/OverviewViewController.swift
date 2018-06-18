//
//  OverviewViewController.swift
//  ChoresForCoinsiOS
//

//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase


class OverviewViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    var isFirstLoad = true
    var coinValue = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let username = Auth.auth().currentUser?.displayName{
            usernameLabel.text = username
            coinAmtLabel.text = "\(coinValue)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            print("Already launched")
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            // on first load of the app it will present the Authorization view
            performSegue(withIdentifier: "toAuthSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
