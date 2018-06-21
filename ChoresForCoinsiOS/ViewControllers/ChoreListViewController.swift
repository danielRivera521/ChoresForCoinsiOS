//
//  ChoreListViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class ChoreListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    var isFirstLoad = true
    var coinValue = 11
    var idFound = false
    var chores: [Chore] = [Chore]()
    var ref: DatabaseReference?
    var userID: String?
    var parentID: String?
    var choreIDNum: String?
    
    @IBOutlet weak var choreListTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //checks if the user has an account in the database
        checkDatabase()
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //initializes chores
        chores = [Chore]()
        //initial table setup
        choreListTable.delegate = self
        choreListTable.dataSource = self
        
        for item in chores {
            print (item.name)
            print(item.key)
        }
        
        //gets the custom parent id created in the registration
        self.getParentId()
        
        //cresates chore list
        createChores()
        choreListTable.reloadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        createChores()
        choreListTable.reloadData()
        if !isUserParent(){
            if  let arrayOfTabBarItems = tabBarController?.tabBar.items as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[1] as? UITabBarItem {
                tabBarItem.isEnabled = false
            }
            
        }
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
        
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("running_total").child(uid).child("coin_total").observeSingleEvent(of: .value) { (snapshot) in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToChoreDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let choreItem = chores[indexPath.row]
        
        cell.textLabel?.text = choreItem.name
        if !(choreItem.completed!)
        {
            cell.accessoryType = .none
            
        } else {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func createChores(){
        //database reference
        ref = Database.database().reference()
        var isCompleted: Bool = false
        chores.removeAll()
        //database handler
        self.ref?.child("chores").observeSingleEvent(of: .value, with: { (snapshot) in
            //if there are children in the database
            if snapshot.childrenCount > 1{
                
                if let value = snapshot.value as? NSDictionary{
                    for id in value.keyEnumerator(){
                        
                        //check for chore ID
                        if let choreID = id as? String {
                            //run another iteration of the database for each individual child in chores to get the parent ID and populate the chore array with the chore name, key and completed attributes.
                            
                            self.ref?.child("chores").child(choreID).observeSingleEvent(of: .value, with: { (newSnapshot) in
                                //gets the parent id
                                let value = newSnapshot.value as? NSDictionary
                                
                                let id = value?["parent_id"] as? String
                                if let actualParentID = id{
                                    
                                    if actualParentID == self.parentID {
                                        let choreCompleted = value?["chore_completed"] as? Bool
                                        if let actualCompleted = choreCompleted {
                                            isCompleted = actualCompleted
                                            
                                        } else {
                                            isCompleted = false
                                        }
                                        let choreName = value?["chore_name"] as? String
                                        if let actualChoreName = choreName {
                                            let newChore = Chore(key: choreID, name: actualChoreName, completed: isCompleted)
                                            
                                            self.chores.append(newChore)
                                            self.choreListTable.reloadData()
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    //gets the parent generated id from the user's node in the database
    func getParentId(){
        if let actualUID = userID{
            _ = Database.database().reference().child("user").child(actualUID).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let id = value?["parent_id"] as? String
                if let actualID = id{
                    self.parentID = actualID
                }
            }
        }
        
    }
    
    func isUserParent () -> Bool{
        
        let ref = Database.database().reference()
        let id = Auth.auth().currentUser?.uid
        var boolValue: Bool = false
        
        ref.child("user").child(id!).observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let parentCheck = value?["user_parent"] as? String
            if let actualParentCheck = parentCheck {
                if actualParentCheck.lowercased() == "true"{
                    boolValue = true
                } else {
                    boolValue = false
                }
            }
        
        }
        return boolValue
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChoreDetail"{
            
            let index = self.choreListTable.indexPathForSelectedRow
            choreIDNum = chores[(index?.row)!].key
            if segue.identifier == "goToChoreDetail"{
                let choreDetailVC = segue.destination as? ChoreDetailsViewController
                choreDetailVC?.choreId = choreIDNum
            }
        }
    }
}
