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
    
    var ref: DatabaseReference?
    var coinValue = 11
    var idFound = false
    var userID: String?
    var parentID: String?
    var choreIDNum: String?
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var selectedCellIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        getParentId()
        
        // gets all children with same parent id as user
        getChildren()
        
        getCoinTotals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getCoinTotals() {
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictRunningTotal = dictRoot["running_total"] as? [String:AnyObject] ?? [:]
            var count = 0
            for key in Array(dictRunningTotal.keys) {
                self.coinTotals.append(RunningTotal(dictionary: (dictRunningTotal[key] as? [String:AnyObject])!, key: key))
                
                count += 1
            }
            
            self.childrenTableView.reloadData()
        }
    }
    
    // gets all children with same parent id as user
    func getChildren() {
        children.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictUsers = dictRoot["user"] as? [String:AnyObject] ?? [:]
            var count = 0
            for key in Array(dictUsers.keys) {
                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                self.children = self.children.filter({$0.parentid == self.parentID})
                self.children = self.children.filter({$0.userparent!})
                
                count += 1
            }
            
            self.childrenTableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddRemoveCoinsViewController {
            if let selectedCellIndex = selectedCellIndex {
                if let cointotal = coinTotals[selectedCellIndex].cointotal {
                    destination.coinTotal = cointotal
                    destination.childId = coinTotals[selectedCellIndex].userid
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
    
    
    // MARK: Custom Classes
    class ChildUser {
        var key: String
        var userid: String?
        var username: String?
        var userparent: Bool?
        var parentid: String?
        
        init(dictionary: [String:AnyObject], key: String) {
            self.key = key
            if let userid = dictionary["user_id"] as? String {
                self.userid = userid
            }
            if let username = dictionary["user_name"] as? String {
                self.username = username
            }
            if let userparent = dictionary["user_parent"] as? Bool {
                self.userparent = userparent
            }
            if let parentid = dictionary["parent_id"] as? String {
                self.parentid = parentid
            }
        }
    }
    
    class RunningTotal {
        var key: String
        var userid: String?
        var cointotal: Int?
        
        init(dictionary: [String:AnyObject], key: String) {
            self.key = key
            if let userid = dictionary["child_id"] as? String {
                self.userid = userid
            }
            if let cointotal = dictionary["coin_total"] as? Int {
                self.cointotal = cointotal
            }
        }
    }
}































