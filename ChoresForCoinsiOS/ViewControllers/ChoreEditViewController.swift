//
//  ChoreEditViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import MobileCoreServices

class ChoreEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var choreImageUIButton: UIButton!
    @IBOutlet weak var choreNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var choreDescriptionTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var choreValueTextField: UITextField!
    @IBOutlet weak var choreNoteTextView: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var childRedeemView: UIView!
    @IBOutlet weak var redDot: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    
    private var imagePicker: UIImagePickerController!
    
    // create date picker
    let picker = UIDatePicker()
    
    var ref: DatabaseReference?
    var userID: String?
    var parentID: String?
    var choreId: String?
    var idFound = false
    var coinValue = 0
    var runningTotal = 0
    var isActiveUserParent = false
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    
    var startDateTime: Date?
    var dueDateTime: Date?
    
    var processSegue = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBackground()
        
        childRedeemView.isHidden = true
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //define ref variable
        ref = Database.database().reference()
        
        checkDatabase()
        
        // set up date pickers
        createDatePickerStart()
        createDatePickerDue()
        
        //gets the custom parent id created in the registration
        getParentId()
        
        // get photo for profile button
        getPhoto()
        
        //pre populate choe information from exisitng chore.
        displayChoreInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isUserParent()
        getPhoto()
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
                                    self.displayHeaderName()
                                    return
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
    
    func updateChore(id: String){
        
        //id is the choreID. Takes the information inputted or generated by the form and updates chore.
        processSegue = true
        if let name = choreNameTextField.text{
            
            if self.verifyChoreNameCharacters(choreName: name){
                ref?.child("chores").child(id).updateChildValues(["chore_name" : name])
            } else {
                processSegue = false
                return
            }
            
            
        }
        if let userName = usernameTextField.text{
            
            
            ref?.child("chores").child(id).updateChildValues(["chore_username" : userName])
            
        }
        
        if  let description = choreDescriptionTextView.text {
            
            ref?.child("chores").child(id).updateChildValues(["chore_description" : description])
        }
        
        if let startDate = startDateTextField.text{
            
            ref?.child("chores").child(id).updateChildValues(["start_date" : startDate])
            
        }
        
        if let dueDate = dueDateTextField.text{
            
            ref?.child("chores").child(id).updateChildValues(["due_date" : dueDate])
            
        }
        
        if let choreNote = choreNoteTextView.text{
            
            ref?.child("chores").child(id).updateChildValues(["chore_note" : choreNote])
            
        }
        
        if   let choreValue = choreValueTextField.text{
            
            ref?.child("chores").child(id).updateChildValues(["number_coins" : choreValue])
            
        }
        
        
        // TODO: Add alert that says the chore was saved
        if processSegue{
            dismiss(animated: true) {
                
                AlertController.showAlert(self, title: "Chore Updated", message: "Any values that have been entered for the current Chore have been updated on the current chore.")
                
            }
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
    
    //gets background color from user's settings within firebase
    
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
    
    func isUserParent(){
        
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Bool {
                self.isActiveUserParent = val
                
                if self.isActiveUserParent {
                    self.getRunningTotalParent()
                } else {
                    self.getRunningTotal()
                }
            }
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
                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                self.children = self.children.filter({$0.parentid == self.parentID})
                self.children = self.children.filter({$0.userparent == false})
                
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
    
    func getPhoto() {
        
        let DatabaseRef = Database.database().reference()
        if let uid = userID{
            DatabaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                //gets the image URL from the user database
                if let profileURL = value?["profile_image_url"] as? String{
                    
                    self.profileButton.loadImagesUsingCacheWithUrlString(urlString: profileURL, inViewController: self)
                    //turn button into a circle
                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                    self.profileButton.layer.masksToBounds = true
                }
            }
            
        }
    }
    
    func displayChoreInfo(){
        
        
        if let cid = choreId{
            ref?.child("chores").child(cid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists(){
                    
                    let value = snapshot.value as? NSDictionary
                    
                    if let choreName = value?["chore_name"] as? String {
                        self.choreNameTextField.text = choreName
                    }
                    
                    if let choreDescription = value?["chore_description"] as? String  {
                        self.choreDescriptionTextView.text = choreDescription
                    }
                    
                    if let choreUserName = value?["chore_username"] as? String {
                        self.usernameTextField.text = choreUserName
                    }
                    
                    if let choreStartDate = value?["start_date"] as? String {
                        self.startDateTextField.text = choreStartDate
                    }
                    
                    if let choreDueDate = value?["due_date"] as? String {
                        self.dueDateTextField.text = choreDueDate
                    }
                    
                    if let choreValue = value?["number_coins"] as? String {
                        self.choreValueTextField.text = choreValue
                    }
                    
                    if let choreNote = value?["chore_note"] as? String {
                        self.choreNoteTextView.text = choreNote
                    }
                    
                    if let imageUrl = value?["image_url"] as? String {
                        self.choreImageUIButton.loadImagesUsingCacheWithUrlString(urlString: imageUrl, inViewController: self)
                    }
                }
            })
        }
    }
    
    
    func removeChildNode(child: String){
        if let dbRef = ref?.child("chores").child(child){
            
            dbRef.removeValue()
        }
        
        let storRef = Storage.storage().reference()
        
        storRef.child(child).delete { (error) in
            if let error = error {
                AlertController.showAlert(self, title: "Delete Image from Storage Error", message: error.localizedDescription)
            } else {
                AlertController.showAlert(self, title: "Delete Success", message: "Chore and chore image deleted.")
            }
        }
        
    }
    
    //checks the start date against the due date and will return either true or false.
    func checkDateValid()-> Bool{
        var dueDate: Date
        var startDate: Date
        
        if let checkDueDate = dueDateTime{
            dueDate = checkDueDate
        } else {
            dueDate = Date()
        }
        
        startDate = startDateTime!
        
        if startDate <= dueDate{
            return true
        }
        
        return false
    }
    
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
    
    func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
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
    
    func checkRedeem(children: [ChildUser]) {
        for child in children {
            if let childuid = child.userid {
                Database.database().reference().child("user/\(childuid)/isRedeem").observeSingleEvent(of: .value) { (snapshot) in
                    if let isRedeem = snapshot.value as? Bool {
                        if isRedeem && self.isActiveUserParent {
                            self.redDot.isHidden = false
                        } else {
                            self.redDot.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeChorePicture(_ sender: UIButton) {
        
        //instantiates the imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //if the camera is not available, use the photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
        } else {
            
            //may remove this option if current image from camera is necessary.
            imagePicker.sourceType = .photoLibrary
        }
        
        //image can be edited and sets the mediatype to the source type which is the camera
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //function to access storage
    
    func storeImage(image: UIImage){
        
        let imageName = "\(choreId!)"
        let storageRef = Storage.storage().reference().child("\(imageName).png")
        
        
        if let uploadData = UIImagePNGRepresentation(image) {
            
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    AlertController.showAlert(self, title: "Image Upload Error", message: (error?.localizedDescription)! )
                    return
                }
                
                storageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        AlertController.showAlert(self, title: "Download URL Error", message: error.localizedDescription)
                        return
                    } else {
                        if let urlString = url?.absoluteString{
                            self.createChoreImageURL(imageUrl: urlString)
                        }
                    }
                })
                
            }
            
        }
        
    }
    
    private func createChoreImageURL(imageUrl: String){
        
        let ref = Database.database().reference()
        
        ref.child("chores/\(choreId!)/image_url").setValue(imageUrl)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == (kUTTypeImage as String){
            
            // a photo was taken
            let ref = Database.database().reference().child("chores")
            
            // updates the chore completed from false to true
            ref.child("\(choreId!)").updateChildValues(["chore_completed" : true])
            
            var selectedImageFromPicker: UIImage?
            
            if let editedImage = info["UIImagePickerControllerEditedImage"]{
                // save edited image
                selectedImageFromPicker = editedImage as? UIImage
                
            } else if let originalImage = info["UIImagePickerControllerOriginalImage"]{
                // save original image
                selectedImageFromPicker = originalImage as? UIImage
            }
            
            //selectedImage unwrapped to be saved.
            if let selectedImage = selectedImageFromPicker {
                storeImage(image: selectedImage)
                
            }
            dismiss(animated: true, completion: nil)
            
            
            
        } else {
            // a video was taken and do nothing.
        }
    }
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.performSegue(withIdentifier: "toCoinFromChoreEdit", sender: nil)
                } else {
                    self.childRedeemView.isHidden = false
                }
            }
        })
    }
    
    @IBAction func childRedeem(_ sender: UIButton) {
        if let uid = userID {
            Database.database().reference().child("user/\(uid)/isRedeem").setValue(true)
            
            childRedeemView.isHidden = true
            
            AlertController.showAlert(self, title: "Redeemed", message: "Your coin redeem has been requested. We'll let your parent know!")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteChore(_ sender: UIButton) {
        if let choreName = choreNameTextField.text {
            let deleteAlert = UIAlertController(title: "Are you Sure?", message: "Do you want to delete \(choreName)?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
                if let id = self.choreId {
                    self.removeChildNode(child: id)
                    self.performSegue(withIdentifier: "segueToList", sender: self)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            deleteAlert.addAction(deleteAction)
            deleteAlert.addAction(cancelAction)
            
            present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    //calls the updatechore function to rewrite the chore object
    @IBAction func saveChore(_ sender: UIButton) {
        
        if let cid = choreId {
            updateChore(id: cid)
            
            //checks if the coin value text field is empty and a integer or sets the processSegue is set to false.
            if let coinValue = choreValueTextField.text{
                if isStringAnInt(string: coinValue){
                    processSegue = true
                } else {
                    choreValueTextField.becomeFirstResponder()
                    AlertController.showAlert(self, title: "Coin Value Not Dectected", message: "Please enter a numeric integar value for how many coins this chore is worth.")
                    processSegue = false
                }
            } else {
                AlertController.showAlert(self, title: "Coin Value Not Dectected", message: "Please enter a numeric integar value for how many coins this chore is worth.")
            }
            
            if let startDateString = startDateTextField.text {
                if let dueDateString = dueDateTextField.text {
                    if isValidDate(dateString: startDateString) && isValidDate(dateString: dueDateString){
                        processSegue = true
                    } else {
                        AlertController.showAlert(self, title: "Chore Date Error", message: "Please be sure that valid dates are being used for the chore start and due dates.")
                        processSegue = false
                    }
                }
            }
            
            if processSegue{
                performSegue(withIdentifier: "segueToList", sender: self)
            }
        }
    }
    
}
