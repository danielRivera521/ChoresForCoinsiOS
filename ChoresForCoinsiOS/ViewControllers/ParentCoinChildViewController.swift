//
//  ParentCoinChildViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/22/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class ParentCoinChildViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var childrenTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    var ref: DatabaseReference?
    var coinValue = 11
    var idFound = false
    var firstRun = true
    var userID: String?
    var parentID: String?
    var choreIDNum: String?
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var selectedCellIndex: Int?
    var isParent = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //edit header information
        let name = Auth.auth().currentUser?.displayName
        if name != nil {
            displayHeaderName()
            //getRunningTotal()
            
        }
        
        getParentId()
        
        // gets all children with same parent id as user
        getChildren()
        
        // gets coin totals for all children
        getCoinTotals()
        
        // get photo for profile button
        getPhoto()
    }
    
    func displayHeaderName(){
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                if let name = value?["user_name"] as? String{
                    self.usernameLabel.text = name
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !firstRun {
            getRunningTotalParent()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        firstRun = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getRunningTotalParent(){
        
        getChildren()
        getCoinTotals()
    }
    
    func getParentId(){
        if let actualUID = userID{
            _ = Database.database().reference().child("user").child(actualUID).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let id = value?["parent_id"] as? String
                if let actualID = id{
                    self.parentID = actualID
                    print(actualID)
                }
            }
        }
        
    }
    
    // gets all children with same parent id as user
    func getChildren() {
        children.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictUsers = dictRoot["user"] as? [String:AnyObject] ?? [:]

            for key in Array(dictUsers.keys) {
                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                self.children = self.children.filter({$0.parentid == self.parentID})
                self.children = self.children.filter({$0.userparent == false})
                
            }
            
            
            self.childrenTableView.reloadData()
        }
        
       
    }
    
    func getCoinTotals() {
        //coinTotals.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictRunningTotal = dictRoot["running_total"] as? [String:AnyObject] ?? [:]
        
            for key in Array(dictRunningTotal.keys) {
                self.coinTotals.append(RunningTotal(dictionary: (dictRunningTotal[key] as? [String:AnyObject])!, key: key))

            }
            
            
            self.childrenTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddRemoveCoinsViewController {
            if let selectedCellIndex = selectedCellIndex {
                if let cointotal = coinTotals[selectedCellIndex].cointotal {
                    destination.coinValue = cointotal
                    destination.childId = children[selectedCellIndex].userid
                }
            }
        }
    }
    
    func getPhoto() {
        var uid = ""
        if let UID = Auth.auth().currentUser?.uid {
            uid = UID
        }
        
        Database.database().reference().child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? [String:Any] {
                // get profile picture
                if let filename = val["profilePicture"] as? String {
                    let fileref = Storage.storage().reference().child(filename)
                    fileref.getData(maxSize: 100000000, completion: { (data, error) in
                        if error == nil {
                            if data != nil {
                                let img = UIImage.init(data: data!)
                                
                                // make sure UI is getting updated on Main thread
                                DispatchQueue.main.async {
                                    self.profileButton.setBackgroundImage(img, for: .normal)
                                    // turn button into a circle
                                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                                    self.profileButton.layer.masksToBounds = true
                                }
                                
                            }
                        } else {
                            print(error?.localizedDescription)
                        }
                    })
                }
            }
        }
    }
    
    // MARK: Table View setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = children[indexPath.row].username
        if !coinTotals.isEmpty {
            if let cointotal = coinTotals[indexPath.row].cointotal {
                cell.detailTextLabel?.text = String(cointotal)
            }
        }
        
        selectedCellIndex = indexPath.row
        
        return cell
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToChildList(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
}






























