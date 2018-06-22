//
//  ParentCoinChildrenViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/21/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class ParentCoinChildrenViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var children = [UserModel] ()
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            ref?.child("user/\(uid)/parent_id").observe(.value, with: { (snapshot) in
                if let parentID = snapshot.value as? String {
                    self.findChildren(parentID: parentID)
                    
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findChildren(parentID: String) {
        ref?.child("user").observeSingleEvent(of: .value, with: { (snapshot) in
            if let allUsers = snapshot.value as? [String:AnyObject] {
                for (_, values) in allUsers {
                    var uid = ""
                    var parentId = ""
                    var username = ""
                    var isParent: Bool?
                    
                    if let uidUnwrapped = values["user_id"] as? String {
                        uid = uidUnwrapped
                    }
                    if let parentIdUnwrapped = values["parent_id"] as? String {
                        parentId = parentIdUnwrapped
                    }
                    if let usernameUnwrapped = values["user_name"] as? String {
                        username = usernameUnwrapped
                    }
                    if let isParentUnwrapped = values["user_parent"] as? Bool {
                        isParent = isParentUnwrapped
                    }
                    
                    if let userParent = isParent {
                        if parentID == parentId && !userParent {
                            // find coin total
                            
                            self.children.append(UserModel(mID: uid, mGeneratedID: parentId, mUserName: username, mIsParent: false.description, mCoinTotal: nil))
                        }
                    }
                }
            }
        })
    }
    
    // MARK: TableView setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = children[indexPath.row].userName
        //cell.detailTextLabel?.text = "\(children[indexPath.row].coinTotal ?? 0)"
        
        return cell
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
