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
    @IBOutlet weak var redDot: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    
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
    var isRedeem = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBackground()
        
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
            coinValue = 0
            getRunningTotalParent()
            // get photo for profile button
            getPhoto()
            
            childrenTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        firstRun = false
    }
    
    func getBackground() {
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("user/\(uid)/bg_image").observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? Int {
                    switch value {
                    case 0:
                        self.bgImage.image = #imageLiteral(resourceName: "whiteBG")
                    case 1:
                        self.bgImage.image = #imageLiteral(resourceName: "orangeBG")
                    case 2:
                        self.bgImage.image = #imageLiteral(resourceName: "greenBG")
                    case 3:
                        self.bgImage.image = #imageLiteral(resourceName: "redBG")
                    case 4:
                        self.bgImage.image = #imageLiteral(resourceName: "purpleBG")
                    default:
                        self.bgImage.image = #imageLiteral(resourceName: "whiteBG")
                    }
                }
            }
        }
        
        
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
        }
        
        
    }
    
    func getCoinTotals() {
        coinTotals.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictRunningTotal = dictRoot["running_total"] as? [String:AnyObject] ?? [:]
            
            for key in Array(dictRunningTotal.keys) {
                for child in self.children {
                    if key == child.userid {
                        self.coinTotals.append(RunningTotal(dictionary: (dictRunningTotal[key] as? [String:AnyObject])!, key: key))
                    }
                }
            }
            
            var sumTotal = 0
            
            for coinAmt in self.coinTotals{
                if let total = coinAmt.cointotal{
                    sumTotal += total
                }
            }
            self.coinAmtLabel.text = String(sumTotal)
            self.childrenTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        firstRun = false
        if let destination = segue.destination as? AddRemoveCoinsViewController {
            if let selectedCellIndex = selectedCellIndex {
                if let cointotal = coinTotals[selectedCellIndex].cointotal {
                    destination.coinValue = cointotal
                    destination.childId = children[selectedCellIndex].userid
                    destination.childName = children[selectedCellIndex].username
                    if let redeem = self.children[selectedCellIndex].isRedeem {
                        destination.isRedeem = redeem
                    }
                }
            }
        }
    }
    
    func getPhoto() {
        
        let DatabaseRef = Database.database().reference()
        if let uid = userID{
            DatabaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                //gets the image URL from the user database
                if let profileURL = value?["profile_image_url"] as? String{
                  
                    let url = URL(string: profileURL)
                    ImageService.getImage(withURL: url!, completion: { (image) in
                        
                        self.profileButton.setBackgroundImage(image, for: .normal)
                    })
                    
                //    self.profileButton.loadImagesUsingCacheWithUrlString(urlString: profileURL, inViewController: self)
                    //turn button into a circle
                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                    self.profileButton.layer.masksToBounds = true
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
        
        if let username = children[indexPath.row].username {
            if children.count > 0 {
                if let redeem = children[indexPath.row].isRedeem {
                    if redeem {
                        cell.textLabel?.text = "\(username): REDEEM PENDING"
                    } else {
                        cell.textLabel?.text = username
                    }
                } else {
                    cell.textLabel?.text = username
                }
            }
        }
        
        if !coinTotals.isEmpty {
            if let cointotal = coinTotals[indexPath.row].cointotal {
                cell.detailTextLabel?.text = String(cointotal)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndex = indexPath.row
        performSegue(withIdentifier: "goToCalc", sender: self)
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToChildList(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
}


