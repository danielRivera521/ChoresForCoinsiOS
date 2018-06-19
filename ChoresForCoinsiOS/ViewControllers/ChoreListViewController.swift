//
//  ChoreListViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class ChoreListViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    var isFirstLoad = true
    var coinValue = 11
    var idFound = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDatabase() {
        
        let databaseRef = Database.database().reference().child("user")
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.observe(.value) { (snapshot) in
                
                if snapshot.exists(){
                    if let userIdDictionary = snapshot.value as? NSDictionary{
                        for id in userIdDictionary.keyEnumerator(){
                            if let userID = id as? String{
                                if userID == uid {
                                    // user is in database
                                    self.idFound = true
                                    if let username = Auth.auth().currentUser?.displayName{
                                        self.getRunningTotal()
                                        self.usernameLabel.text = username
                                        self.coinAmtLabel.text = "\(self.coinValue)"
                                        return
                                    }

                                }
                            }
                        }
                    }
                }
                
            }
        
        }
        if !idFound {
            
            //user not in the database. Registration segue is called
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "parentChildVC") as? ParentChildViewController
            self.navigationController?.pushViewController(vc!, animated: true)

        }
        
    }
    
    func getRunningTotal(){
        
        let databaseRef = Database.database().reference().child("running_total")
        
        if let uid = Auth.auth().currentUser?.uid {
        
            let _ = databaseRef.child(uid).child("coin_total").observe(.value) { (snapshot) in
                if let value = snapshot.value as? Int{
                    self.coinValue = value
                }
            }
        }
    }
    
}
