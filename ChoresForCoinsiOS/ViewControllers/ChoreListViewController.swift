//
//  ChoreListViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class ChoreListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var choreListTV: UITableView!
    
    var chores: [Chore] = [Chore]()
    var coinValue = 11
    var idFound = false
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        createChores()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ref?.child("user").removeAllObservers()
        ref?.removeAllObservers()
    }
    
    func createChores(){
        
        ref?.observe(.value) { (snapshot) in
            let dictRoot = snapshot.value as? [String : AnyObject] ?? [:]
            let dictChores = dictRoot["chores"] as? [String : AnyObject] ?? [:]
            for key in Array(dictChores.keys){
                self.chores.append(Chore(dictionary: (dictChores[key] as? [String : AnyObject])!, key: key))
                
            }
            self.choreListTV.reloadData()
            print (dictChores)
        }
        
    }
    
    func checkDatabase() {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            ref?.child("user").observe(.value) { (snapshot) in
                
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
        
        if let uid = Auth.auth().currentUser?.uid {
            
            ref?.child("running_total").child(uid).child("coin_total").observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                self.coinValue = snapshot.value as? Int ?? 0
                self.coinAmtLabel.text = "\(self.coinValue)"
            }
        }
    }
    
    //MARK: TableView set up
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChoreCellTableViewCell
        
        let choreItem = chores[indexPath.row]
        
        cell.choreNameCellLabel.text = choreItem.name
        
        if let completed = choreItem.completed {
            if completed {
                cell.completedImageCellImageView.image = #imageLiteral(resourceName: "checkmark")
            } else {
                cell.completedImageCellImageView.image = #imageLiteral(resourceName: "redX")
            }
        }
        
        cell.usernameCellLabel.text = choreItem.choreUsername
        cell.dueDateCellLabel.text = choreItem.dueDate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
