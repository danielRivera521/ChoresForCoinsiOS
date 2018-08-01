//
//  TakePictureViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import MobileCoreServices


class TakePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var childRedeemView: UIView!
    @IBOutlet weak var redDot: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var redeemAlertImageView: UIImageView!
    
    var userID: String?
    var parentID: String?
    var choreId: String?
    var coinValue = 0
    var isActiveUserParent = false
    var children = [ChildUser] ()
    var coinTotals = [RunningTotal] ()
    var requestRedeem = false
    
    var coinConversion: Double = 1
    
    private var imagePicker: UIImagePickerController!
    
    var animRedeemAlertContainer = [UIImage] ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redeemAlertImageView.isHidden = true
        
        getBackground()
        
        childRedeemView.isHidden = true
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //edit header information
        let name = Auth.auth().currentUser?.displayName
        if let username = name {
            usernameLabel.text = username
        }
        
        // get photo for profile button
        getPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isUserParent()
        getPhoto()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        performSegue(withIdentifier: "segueToList", sender: self)
    }
    
    private func createChoreImageURL(imageUrl: String){
        
        let ref = Database.database().reference()
        
        ref.child("chores/\(choreId!)/image_url").setValue(imageUrl)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == (kUTTypeImage as String){
            
            
            // a photo was taken. create teh database reference and get the date time stamp
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM//dd/yyyy"
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: currentDate)
            let ref = Database.database().reference().child("chores")
            
            // updates the chore completed from false to true
            ref.child("\(choreId!)").updateChildValues(["chore_completed" : true])
            ref.child("\(choreId!)/date_completed").setValue(dateString)
            ref.child("\(choreId!)/assigned_child_id").setValue(userID!)
            if let displayName = Auth.auth().currentUser?.displayName{
                
                // let displayText = "Completed by \(displayName)"
                let displayText = "\(displayName)"
                ref.child("\(choreId!)/chore_username").setValue(displayText)
                
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let dateString = formatter.string(from: now)
                ref.child("\(choreId!)/date_completed").setValue(dateString)
                
            }
           
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
                let reOrientatedImage = selectedImage.fixOrientation()
                storeImage(image: reOrientatedImage)
                
            }
            
            dismiss(animated: true, completion: nil)
            
            
        } else {
            // a video option is selected
            AlertController.showAlert(self, title: "Not Available", message: "The Video Option is not available at this time")
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        AlertController.showAlert(self, title: "No Picture Selected", message: "Please take an Image with your camera of the completed chore to complete this chore.")
    }
    
    func getPhoto() {
        let userID = Auth.auth().currentUser?.uid
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
             //       self.profileButton.loadImagesUsingCacheWithUrlString(urlString: profileURL, inViewController: self)
                    //turn button into a circle
                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                    self.profileButton.layer.masksToBounds = true
                }
            }
            
        }
    }
    
    func getConversionRate(){
        if let unwrappedParentID = parentID{
            
            Database.database().reference().child("app_settings").child(unwrappedParentID).observeSingleEvent(of: .value, with: { (snapshot) in
                
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
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.performSegue(withIdentifier: "toCoinFromTakePhoto", sender: nil)
                } else {
                    self.childRedeemView.isHidden = false
                }
            }
        })
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
                    Database.database().reference().child("user/\(uid)/isRedeem").setValue(true)
                    Database.database().reference().child("running_total/\(uid)/isRedeem").setValue(true)
                    self.childRedeemView.isHidden = true
                    self.requestRedeem = true
                    
                    AlertController.showAlert(self, title: "Redeemed", message: "Your coin redeem has been requested. We'll let your parent know!")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.childRedeemView.isHidden = true
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
            } else {
                AlertController.showAlert(self, title: "Redeem Request", message: "You have already requested your coins to be redeemed. Your parent must complete this to access this feature again.")
            }
        }

    }
    
    @IBAction func doGoBack(_ sender: UIButton) {
    }
    
    @IBAction func takePictureBtn(_ sender: UIButton) {
        
        //instantiates the imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //if the camera is not available, use the photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        } else {
            
            //may remove this option if current image from camera is necessary.
            imagePicker.sourceType = .photoLibrary
        }
        
        //image can be edited and sets the mediatype to the source type which is the camera
        imagePicker.allowsEditing = true
        
        //imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)
        
        
        self.present(imagePicker, animated: true, completion: nil)
    }
}
