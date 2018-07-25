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
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var childRedeemView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var redDot: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var redeemAlertImageView: UIImageView!
    
    // MARK: - Properties
    
    var coinValue = 11
    var idFound = false
    var ref: DatabaseReference?
    var userID: String?
    var parentID: String?
    var firstView = true
    var isActiveUserParent = false
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var isLandscape = false
    var coinConversion: Double = 1
    
    var bgImg: UIImage?
    var animRedeemView: UIImageView?
    var animRedeemAlertContainer = [UIImage] ()
    
    // MARK: - ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redeemAlertImageView.isHidden = true
        
        // get animation ready
        animRedeemView = AnimationHelper.createRedeemAnim(vc: self)
        
        //gets the background color
        
        getBackground()
        
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
        
        //gets the background color
        getBackground()
        
        loadPage()
        
    }
    
    // MARK: - Custom Methods
    
    func loadPage() {
        
        childRedeemView.isHidden = true
        
        firstView = true
        ref = Database.database().reference()
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //initial table setup
//        choreListTV.delegate = self
//        choreListTV.dataSource = self
        
        
        //gets the custom parent id created in the registration
        getParentId()
        
        //check if user is a parent. if the account is a child account the add chore tab will be disabled.
       // isUserParent()
        
        //checks if the user has an account in the database
        checkDatabase()
        
        //edit header information
        displayHeaderName()
        
        // get photo for profile button
        getPhoto()
        
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
                                    if (Auth.auth().currentUser?.displayName) != nil{
                                        self.isUserParent()
                                        self.displayHeaderName()
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
    
    func getRunningTotalParent(){
        getChildren()
        getCoinTotals()
    }
    
    // gets all children with same parent id as user
    func getChildren() {
        children.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictUsers = dictRoot["user"] as? [String:AnyObject] ?? [:]
            
            for key in Array(dictUsers.keys) {
                let results = self.children.filter { $0.key == key }
                let exists = results.isEmpty == false
                
                if !exists {
                    self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                    self.children = self.children.filter({$0.parentid == self.parentID})
                    self.children = self.children.filter({$0.userparent == false})
                }
                
            }
            
            self.checkRedeem(children: self.children)
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
            for coinTotal in self.coinTotals {
                if let total = coinTotal.cointotal{
                    sumTotal += total
                }
            }
            self.coinAmtLabel.text = String(sumTotal)
            print("Count of Children: \(self.children.count)")
            print("Count of CoinTotals: \(self.coinTotals.count)")
       
        }
       
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
    
    func isUserParent(){
        
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Bool {
                self.isActiveUserParent = val
                //self.disableAddChoreTabItem()
                
                if self.isActiveUserParent {
                    self.getRunningTotalParent()
                } else {
                    self.getRunningTotal()
                }
            }
        }
        
    }
    
    func disableAddChoreTabItem(){
        if let arrayOfTabBarItems = tabBarController?.tabBar.items as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[2] as? UITabBarItem {
            tabBarItem.isEnabled = isActiveUserParent
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
                    
                    //  self.profileButton.loadImagesUsingCacheWithUrlString(urlString: profileURL, inViewController: self)
                    //turn button into a circle
                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                    self.profileButton.layer.masksToBounds = true
                }
            }
        }
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
    
    func checkRedeem(children: [ChildUser]) {
        
        self.redDot.isHidden = true
        for child in children {
            
            if let childuid = child.userid {
                Database.database().reference().child("user/\(childuid)/isRedeem").observeSingleEvent(of: .value) { (snapshot) in
                    if let isRedeem = snapshot.value as? Bool {
                        if isRedeem && self.isActiveUserParent {
                            self.redDot.isHidden = false
                            
                            self.redeemAlertImageView.isHidden = false
                            
                            // set up alert animation
                            for i in 0...29 {
                                if i < 10 {
                                    self.animRedeemAlertContainer.append(UIImage(named: "anim_redeemAlert_00\(i)")!)
                                } else {
                                    self.animRedeemAlertContainer.append(UIImage(named: "anim_redeemAlert_0\(i)")!)
                                }
                            }
                            
                            self.redeemAlertImageView.animationImages = self.animRedeemAlertContainer
                            
                            self.redeemAlertImageView.startAnimating()
                        } else {
                            self.redeemAlertImageView.stopAnimating()
                            self.redeemAlertImageView.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    func alertCompletedAddNote(chore: Chore){
        if let completedNotifyString = chore.choreCompletedNotified {
            if completedNotifyString == "yes" {
                //parent was already notified
                return
            }
            // if completedNotify String does not exist
        } else {
            let key = chore.key
            if let childName = chore.choreUsername{
                let addNoteAlert = UIAlertController(title: "Chore Completed", message: "The chore named \(chore.name!) was completed by \(childName). Please write a note regarding the completion of this chore.", preferredStyle: UIAlertControllerStyle.alert)
                let saveNote = UIAlertAction(title: "Save", style: .default) { (saveAction) in
                    //read text from the alert box
                    let noteTextField = addNoteAlert.textFields![0] as UITextField
                    if let noteString = noteTextField.text {
                        //save text to the chore.
                        self.ref?.child("chores/\(key)/chore_note").setValue(noteString)
                        self.ref?.child("chores/\(key)/chore_completed_notified").setValue("yes")
                        
                        addNoteAlert.dismiss(animated: true, completion: nil)
                        
                    } else {
                        
                        AlertController.showAlert(self, title: "Missing Text", message: "Please type in text into the note box.")
                        
                    }
                    
                }
                
                addNoteAlert.addTextField { (textField) in
                    textField.placeholder = "Enter chore note"
                }
                addNoteAlert.addAction(saveNote)
                
                
                present(addNoteAlert, animated: true, completion: nil)
                
                chore.choreCompletedNotified = "yes"
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCoinFromChoresList" {
            if let destination = segue.destination as? ParentCoinChildViewController {
                destination.fromDetailsOrEdit = true
                destination.children = self.children
                destination.coinTotals = self.coinTotals
            }
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.redeemAlertImageView.stopAnimating()
                    self.performSegue(withIdentifier: "toCoinFromChoresList", sender: nil)
                } else {
                    self.childRedeemView.isHidden = false
                }
            }
        })
    }
    
    @IBAction func childRedeem(_ sender: UIButton) {
        if coinValue <= 0 {
            AlertController.showAlert(self, title: "Cannot Redeem", message: "YOu do not have any coins to redeem. Try completing some chores to get some coins")
        } else {
          //  getConversionRate()
            let convertedValue = coinConversion * Double(coinValue)
            let dollarValueString = String(format: "$%.02f", convertedValue)
            
            let alert = UIAlertController(title: "Coin Redemption Requested", message: "You are currently requesting to have your coins redeemed. At the current rate you will receive \(dollarValueString) for the coins you have acquired.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                if let uid = self.userID {
                    self.ref?.child("user/\(uid)/isRedeem").setValue(true)
                    
                    self.childRedeemView.isHidden = true
                    
                    if let animRedeemView = self.animRedeemView {
                        AnimationHelper.startAnimation(vc: self, animView: animRedeemView, anim: 0)
                    }
                    
                    // AlertController.showAlert(self, title: "Redeemed", message: "Your coin redeem has been requested. We'll let your parent know!")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.childRedeemView.isHidden = true
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
    
        }
    }
    
    @IBAction func unwindToChoreList(segue:UIStoryboardSegue) { }
    
}

