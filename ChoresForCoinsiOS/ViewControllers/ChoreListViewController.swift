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
    @IBOutlet weak var childRedeemView: UIView!
    
    var chores: [Chore] = [Chore]()
    var coinValue = 11
    var idFound = false
    var ref: DatabaseReference?
    var userID: String?
    var parentID: String?
    var choreIDNum: String?
    var firstView = true
    
//    var children = [ChildUser] ()
//    var coinTotals = [RunningTotal] ()
//    var runningTotal = 0
//    var isParent = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        childRedeemView.isHidden = true
        
        firstView = true
        ref = Database.database().reference()
        
        //checks if the user has an account in the database
        checkDatabase()
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //initial table setup
        choreListTV.delegate = self
        choreListTV.dataSource = self
        
        //gets the custom parent id created in the registration
        getParentId()
        
        //cresates chore list
        createChores()
        
        //edit header information
        let name = Auth.auth().currentUser?.displayName
        if let username = name {
            usernameLabel.text = username
            getRunningTotal()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ref?.child("user").removeAllObservers()
        ref?.removeAllObservers()
         firstView = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !firstView{
            createChores()
            getRunningTotal()
        }
        
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
    
//    func checkIfParent() {
//        // check if parent
//        if let actualID = userID {
//            _ = Database.database().reference().child("user").child(actualID).child("user_parent").observeSingleEvent(of: .value) { (snapshot) in
//                if let isparent = snapshot.value as? Bool {
//                    self.isParent = isparent
//                }
//            }
//        }
//    }
    
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
    
//    func getRunningTotalParent(){
//
//        getChildren()
//        getCoinTotals()
//    }
    
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
    
    func createChores(){
        //database reference
        ref = Database.database().reference()
        
        chores.removeAll()
        //
        self.ref?.observe(.value) { (snapshot) in
            let dictRoot = snapshot.value as? [String : AnyObject] ?? [:]
            let dictChores = dictRoot["chores"] as? [String : AnyObject] ?? [:]
            var count = 0
            for key in Array(dictChores.keys){
                
                self.chores.append(Chore(dictionary: (dictChores[key] as? [String : AnyObject])!, key: key))
                
                self.chores = self.chores.filter({$0.parentID == self.parentID })
                
                
                count += 1
                
                print("count = \(count)")
            }
            self.choreListTV.reloadData()
            print(self.chores.count)
        }
        
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
    
//    // gets all children with same parent id as user
//    func getChildren() {
//        children.removeAll()
//
//        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
//            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
//            let dictUsers = dictRoot["user"] as? [String:AnyObject] ?? [:]
//            var count = 0
//            for key in Array(dictUsers.keys) {
//                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
//                self.children = self.children.filter({$0.parentid == self.parentID})
//                self.children = self.children.filter({$0.userparent! == false})
//
//                count += 1
//            }
//        }
//
//    }
//
//    func getCoinTotals() {
//        coinTotals.removeAll()
//
//        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
//            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
//            let dictRunningTotal = dictRoot["running_total"] as? [String:AnyObject] ?? [:]
//            var count = 0
//            for key in Array(dictRunningTotal.keys) {
//                self.coinTotals.append(RunningTotal(dictionary: (dictRunningTotal[key] as? [String:AnyObject])!, key: key))
//
//                count += 1
//            }
//
//            var sumTotal = 0
//
//            for coinTotal in self.coinTotals {
//                for child in self.children {
//                    if coinTotal.userid == child.userid {
//                        if let total = coinTotal.cointotal {
//                            sumTotal += total
//                        }
//                    }
//                }
//            }
//
//            self.coinAmtLabel.text = String(sumTotal)
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChoreDetail"{
            
            let index = self.choreListTV.indexPathForSelectedRow
            choreIDNum = chores[(index?.row)!].key
            if segue.identifier == "goToChoreDetail"{
                let choreDetailVC = segue.destination as? ChoreDetailsViewController
                if choreIDNum != nil {
                    choreDetailVC?.choreId = choreIDNum!
                }
            }
        }
    }
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.performSegue(withIdentifier: "toCoinFromChoresList", sender: nil)
                } else {
                    self.childRedeemView.isHidden = false
                }
            }
        })
    }
    
    @IBAction func childRedeem(_ sender: UIButton) {
        // zero out coin total and update db
        
        childRedeemView.isHidden = true
    }
}

