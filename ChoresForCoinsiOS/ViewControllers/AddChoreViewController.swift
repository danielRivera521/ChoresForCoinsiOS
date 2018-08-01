//
//  AddChoreViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

class AddChoreViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var choreImageUIButton: UIButton!
    @IBOutlet weak var choreNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var choreValueTextField: UITextField!
    @IBOutlet weak var choreNoteTextView: UITextView!
    @IBOutlet weak var childRedeemView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var redDot: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var redeemAlertImageView: UIImageView!
    
    
    // MARK: Properties
    
    var isFirstLoad = true
    var coinValue = 0
    var ref: DatabaseReference?
    // create date picker
    let picker = UIDatePicker()
    let childPicker = UIPickerView()
    
    // array to hold all users with same generatedId
    var family = [UserModel] ()
    
    var currentUID: String?
    var userID: String?
    var parentID: String?
    var runningTotal = 0
    var isParent = true
    var isActiveUserParent = false
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    
    var startDateTime: Date?
    var dueDateTime: Date?
    
    var coinConversion: Double = 1
    var selectedRow = 0
    
    var displayName: String?
    
    
    var processSegue = true
    var animRedeemView: UIImageView?
    var animRedeemAlertContainer = [UIImage] ()
    var requestRedeem = false
    
    
    // MARK: View Controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redeemAlertImageView.isHidden = true
        
        // get animation ready
        animRedeemView = AnimationHelper.createRedeemAnim(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadPage()
    }
    
    func loadPage(){
        
        
        // set textfield delegates
        choreNameTextField.delegate = self
        usernameTextField.delegate = self
        choreValueTextField.delegate = self
        
        //sets the background color for the view controller based on the user's settings
        getBackground()
        
        childRedeemView.isHidden = true
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        if (Auth.auth().currentUser?.displayName) != nil{
            displayHeaderName()
            ref = Database.database().reference()
            
            // set up date pickers
            createDatePickerStart()
            createDatePickerDue()
            
            
            
            //acquire parent ID
            getParentId()
        }
        
        isUserParent()
        
        // get profile photo for profile button
        getPhoto()
        
        isFirstLoad = false
        
        //disable the dueDate. it will be enabled able the start date is completed.
        dueDateTextField.isEnabled = false
        
        choreDescriptionTextView.delegate = self
        
        // set up child picker
        createChildPicker()
        
        //set placeholder for Username and hide and disable the chore notes section
        usernameTextField.placeholder = "Click to Assign chore to a child"
        choreNoteTextView.isHidden = true
        
        //sets both start and end date fields with the current date.
        startDateTextField.delegate = self
        dueDateTextField.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 5{
            // format date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: picker.date)
            startDateTextField.text = "\(dateString)"
        }
        if textField.tag == 6{
            // format date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: picker.date)
            dueDateTextField.text = "\(dateString)"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Chore Description TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
    }
    
    //MARK: UIPickerView Functions
    //Picker item lists the children of the parent to be selected to assign
    //the chore.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return children.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return children[row].username
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let nameString = children[row].username{
            
            let compoundString = "Assigned to: \(nameString)"
            selectedRow = row
            
            usernameTextField.text = compoundString
        }
    }
    
    func createChildPicker() {
        // create toolbar for done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        childPicker.delegate = self
        childPicker.dataSource = self
        // done button
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedChild))
        toolbar.setItems([done], animated: false)
        
        usernameTextField.inputAccessoryView = toolbar
        usernameTextField.inputView = childPicker
        
    }
    
    //when doneis pressed if the field is empty, the picker will selected the first child.
    @objc func donePressedChild() {
        if (usernameTextField.text?.isEmpty)! {
            if let nameString = children[0].username{
                
                let compoundString = "Assigned to: \(nameString)"
                selectedRow = 0
                
                usernameTextField.text = compoundString
            }
        }
        //dismiss picker
        self.view.endEditing(true)
        
    }
    
    // MARK: Custom functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss keyboard when user touches outside of keyboard
        self.view.endEditing(true)
    }
    
    //function will check the user's setting the set the background of the view controller.
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
    
    //sets the user's name on the header bar
    func displayHeaderName(){
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                if let name = value?["user_name"] as? String{
                    self.usernameLabel.text = name
                    self.displayName = name
                }
            }
        }
    }
    
    //checks if the user is a parent
    
    func isUserParent(){
        
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Bool {
                self.isActiveUserParent = val
                
                if self.isActiveUserParent {
                    self.getRunningTotalParent()
                } else {
                    self.userNameView.isHidden = true
                    self.getRunningTotal()
                }
            }
        }
    }
    
    //gets the running total of the child and displays it on the header.
    func getRunningTotal(){
        
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("running_total").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if let coins = value?["coin_total"] as? Int{
                    self.coinValue = coins
                }
                if let redeemedCheck = value?["isRedeem"] as? Bool {
                    self.requestRedeem = redeemedCheck
                }
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
                for child in self.children {
                    if coinTotal.key == child.userid {
                        if let total = coinTotal.cointotal {
                            sumTotal += total
                        }
                    }
                }
            }
            
            self.coinAmtLabel.text = String(sumTotal)
        }
    }
    
    func createDatePickerStart() {
        // create toolbar for done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedStart))
        toolbar.setItems([done], animated: false)
        
        startDateTextField.inputAccessoryView = toolbar
        startDateTextField.inputView = picker
        
        // format picker for date only
        picker.datePickerMode = .date
    }
    
    func createDatePickerDue() {
        // create toolbar for done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedDue))
        toolbar.setItems([done], animated: false)
        
        dueDateTextField.inputAccessoryView = toolbar
        dueDateTextField.inputView = picker
        
        // format picker for date only
        picker.datePickerMode = .date
    }
    
    @objc func donePressedStart() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: picker.date)
        
        startDateTime = picker.date
        dueDateTextField.isEnabled = true
        
        if checkDateValid(){
            
            startDateTextField.text = "\(dateString)"
            self.view.endEditing(true)
        } else {
            AlertController.showAlert(self, title: "Date Error", message: "The start date must be older than the due date.")
        }
    }
    
    @objc func donePressedDue() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: picker.date)
        
        dueDateTime = picker.date
        
        //checks the due date against the start date.
        if checkDateValid(){
            dueDateTextField.text = "\(dateString)"
            self.view.endEditing(true)
        } else {
            AlertController.showAlert(self, title: "Date Error", message: "The start date must be older than the due date.")
        }
    }
    
    //creates initial assignment
    func createAssignmentID(choreID: String){
        let newAssignRef = ref?.child("chore_assignment").childByAutoId()
        let assignID = newAssignRef?.key
        if let assignID = assignID {
            ref?.child("chore_assignment/\(assignID)/chore_id").setValue(choreID)
            ref?.child("chore_assignment/\(assignID)/chore_completed").setValue(false)
        }
        
    }
    
    //checks the start date against the due date and will return either true or false.
    func checkDateValid()-> Bool{
        var dueDate: Date
        var startDate: Date
        
        if let checkDueDate = dueDateTime{
            dueDate = checkDueDate
        } else {
            var components = DateComponents()
            components.setValue(10, for: .year)
            let date = Date()
            let futureDate = Calendar.current.date(byAdding: components, to: date)
            dueDate = futureDate!
        }
        
        
        startDate = startDateTime!
        
        if startDate <= dueDate {
            return true
        }
        
        return false
    }
    
    //checks if the string date is a valid date.
    
    func isValidDate(dateString: String) -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM/dd/yyyy"
        dateFormatterGet.dateStyle = .medium
        if let _ = dateFormatterGet.date(from: dateString) {
            //date parsing succeeded
            return true
        } else {
            //invalid date
            return false
        }
    }
    
    // method to check the number of characters in the title. Title should range from 1-20 characters.
    func verifyChoreNameCharacters(choreName: String) -> Bool{
        
        let characterCount = choreName.count
        
        if characterCount > 20 || characterCount < 1{
            AlertController.showAlert(self, title: "Chore Name Error", message: "The chore name should be between 1 and 20 characters.")
            return false
        }
        return true
        
    }
    //gets the parent generated id from the user's node in the database
    func getParentId(){
        let userID = Auth.auth().currentUser?.uid
        
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
                    
                    //turn button into a circle
                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                    self.profileButton.layer.masksToBounds = true
                    
                }
            }
        }
    }
    
    //gets the conversion rate set by the parent in their settings
    func getConversionRate(){
        if let unwrappedParentID = parentID{
            
            ref?.child("app_settings").child(unwrappedParentID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                if let conversionValue = value?["coin_dollar_value"] as? Double{
                    
                    self.coinConversion = conversionValue
                }
                
            })
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
    
    func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        
        return true
    }
    
    // MARK: Actions
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.performSegue(withIdentifier: "toCoinFromAddChore", sender: nil)
                } else {
                    self.childRedeemView.isHidden = false
                }
            }
        })
    }
    
    @IBAction func saveChore(_ sender: UIButton) {
        //sets the processSegue to true. If it's set to false the chore creation and segue does not occur.
        processSegue = true
        
        if let nameString = choreNameTextField.text{
            if verifyChoreNameCharacters(choreName: nameString){
                //do nothing
            } else {
                choreValueTextField.becomeFirstResponder()
                processSegue = false
                
            }
        }
        
        //checks if the chore has been assigned.
        if let assignee = usernameTextField.text {
            if !assignee.isEmpty{
                //do nothing
            } else {
                
                processSegue = false
                AlertController.showAlert(self, title: "Assign Child", message: "Please assign a child to the chore.")
                
            }
            
        } else {
            processSegue = false
            AlertController.showAlert(self, title: "Assign Child", message: "Please assign a child to the chore.")
        }
        //checks if the coin value text field is empty and a integer or sets the processSegue is set to false.
        if let coinValue = choreValueTextField.text{
            if isStringAnInt(string: coinValue){
                //do nothing
            } else {
                choreValueTextField.becomeFirstResponder()
                AlertController.showAlert(self, title: "Coin Value Not Dectected", message: "Please enter a numeric integar value for how many coins this chore is worth.")
                processSegue = false
            }
        } else {
            
            processSegue = false
        }
        
        if (choreValueTextField.text?.isEmpty)!{
            AlertController.showAlert(self, title: "Coin Value Not Dectected", message: "Please enter a numeric integar value for how many coins this chore is worth.")
            processSegue = false

        }
        
        //checks if the text within both the startDateTextField and dueDate TextField are valid dates.
        if let startDateString = startDateTextField.text {
            if let dueDateString = dueDateTextField.text {
                if isValidDate(dateString: startDateString) && isValidDate(dateString: dueDateString){
                    // do nothing
                } else {
                    AlertController.showAlert(self, title: "Chore Date Error", message: "Please be sure that valid dates are being used for the chore start and due dates.")
                    processSegue = false
                }
            }
        }
        
        
        if processSegue{
            //creates a new chore reference
            let newChoreRef = ref?.child("chores").childByAutoId()
            
            //creates a new key
            let currentChoreId = newChoreRef?.key
            
            
            
            //if the key is valid. Takes the information inputted or generated by the form and creates a new chore.
            if let currentChoreId = currentChoreId {
                ref?.child("chores/\(currentChoreId)/chore_name").setValue(choreNameTextField.text)
                
                ref?.child("chores/\(currentChoreId)/chore_description").setValue(choreDescriptionTextView.text)
                ref?.child("chores/\(currentChoreId)/start_date").setValue(startDateTextField.text)
                ref?.child("chores/\(currentChoreId)/due_date").setValue(dueDateTextField.text)
                ref?.child("chores/\(currentChoreId)/chore_note").setValue(choreNoteTextView.text)
                
                ref?.child("chores/\(currentChoreId)/number_coins").setValue(choreValueTextField.text)
                
                if let pID = self.parentID{
                    ref?.child("chores/\(currentChoreId)/parent_id").setValue(pID)
                }
                
                var cID = ""
                
                if children.count != 0 {
                    cID = children[selectedRow].key
                } else {
                    cID = userID!
                }
                
                ref?.child("chores/\(currentChoreId)/assigned_child_id").setValue(cID)
                if isActiveUserParent{
                    ref?.child("chores/\(currentChoreId)/user_name").setValue(usernameTextField.text)
                    
                } else {
                    if let childName = displayName{
                        ref?.child("chores/\(currentChoreId)/user_name").setValue("Assigned to: \(childName)")
                    }
                }
                
                ref?.child("chores/\(currentChoreId)/chore_completed").setValue("false")
                
                // TODO: Add alert that says the chore was saved
                
                // clear the text fields
                choreNameTextField.text = nil
                usernameTextField.text = nil
                choreDescriptionTextView.text = nil
                startDateTextField.text = nil
                dueDateTextField.text = nil
                choreValueTextField.text = nil
                choreNoteTextView.text = nil
                
                // alert user that chore was saved
                let alert = UIAlertController(title: "Success", message: "Chore Saved", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                    // change tabs programmatically
                    self.tabBarController?.selectedIndex = 0
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    @IBAction func childRedeem(_ sender: UIButton) {
        if coinValue <= 0 {
            AlertController.showAlert(self, title: "Cannot Redeem", message: "You do not have any coins to redeem. Try completing some chores to get some coins")
        } else {
            if !requestRedeem{
            getConversionRate()
            let convertedValue = coinConversion * Double(coinValue)
            let dollarValueString = String(format: "$%.02f", convertedValue)
            
            let alert = UIAlertController(title: "Coin Redemption Requested", message: "You are currently requesting to have your coins redeemed. At the current rate you will receive \(dollarValueString) for the coins you have acquired.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                if let uid = self.userID {
                    self.ref?.child("user/\(uid)/isRedeem").setValue(true)
                    self.ref?.child("running_total/\(uid)/isRedeem").setValue(true)
                    self.childRedeemView.isHidden = true
                    self.requestRedeem = true
                    
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
            else {
                AlertController.showAlert(self, title: "Redeem Request", message: "You have already requested your coins to be redeemed. Your parent must complete this to access this feature again.")
            }
        }
        
    }
    
    @IBAction func changeChorePicture(_ sender: UIButton) {
    }
}
