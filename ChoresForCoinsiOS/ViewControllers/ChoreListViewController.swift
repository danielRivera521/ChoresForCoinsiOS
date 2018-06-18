//
//  ChoreListViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class ChoreListViewController: ViewController {

    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
