//
//  OverviewViewController.swift
//  ChoresForCoinsiOS
//

//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {
    
    var isFirstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
       // Do any additional setup after loading the view.
        
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
