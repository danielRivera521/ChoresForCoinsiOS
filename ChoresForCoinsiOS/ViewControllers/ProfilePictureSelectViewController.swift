//
//  ProfilePictureSelectViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices


class ProfilePictureSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var bgImage: UIImageView!
    
    private var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss keyboard when user touches outside of keyboard
        self.view.endEditing(true)
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
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectProfilePic(_ sender: UIButton) {
        // send selected pic back to previous page
        
        let selectedBtnTag = sender.tag
        var profileImage: UIImage?
        
        switch selectedBtnTag{
        case 1:
            profileImage = #imageLiteral(resourceName: "profilePic1")
        case 2:
            profileImage = #imageLiteral(resourceName: "profilePic2")
        case 3:
            profileImage = #imageLiteral(resourceName: "profilePic3")
        case 4:
            profileImage = #imageLiteral(resourceName: "profilePic4")
        case 5:
            profileImage = #imageLiteral(resourceName: "profilePic5")
        default:
            profileImage = #imageLiteral(resourceName: "profilePic6")
        }
        
        var userID = ""
        if let userid = Auth.auth().currentUser?.uid {
            userID = userid
            let range = userID.index(userID.startIndex, offsetBy: 5)..<userID.endIndex
            userID.removeSubrange(range)
            let filename = "\(userID)ProfilePicture.png"
            let fileref = Storage.storage().reference().child(filename)
            let meta = StorageMetadata()
            meta.contentType = "image/png"
            
            if let img = profileImage {
                fileref.putData(UIImagePNGRepresentation(img)!, metadata: meta, completion: { (meta, error) in
                    if error != nil {
                        AlertController.showAlert(self, title: "Image Upload Error", message: "Error uploading image to storage." )
                        return
                    }
                    
                    fileref.downloadURL(completion: { (url, error) in
                        if let _ = error {
                            AlertController.showAlert(self, title: "Download URL Error", message: "Error in downloading image from the cloud database.")
                            return
                        } else {
                            if let urlString = url?.absoluteString{
                                self.createProfileImageURL(imageUrl: urlString)
                            }
                        }
                    })
                })
            }
            
            infoAlert()
        }
    }
    
    @IBAction func takeProfilePic(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // if the device's camera is functioning and available, set imagePickers source as the camera
        // if not, use photo library instead
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        // lets user edit photos taken with camera or in photo library
        imagePicker.allowsEditing = true
        // sets the media type to the same as the camera or photo library
        
        
        // present the image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: ImagePicker Methods
    
    //function to access storage
    
    
    
    func storeImage(image: UIImage){
        let id = Auth.auth().currentUser?.uid
        if let userId = id {
            let last5 = userId.suffix(5)
            let imageName = "\(last5)ProfilePicture"
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
                                self.createProfileImageURL(imageUrl: urlString)
                            }
                        }
                    })
                }
            }
            
            dismiss(animated: true, completion: nil)
            infoAlert()
            
    
        }
    }
    
    private func createProfileImageURL(imageUrl: String){
        let id = Auth.auth().currentUser?.uid
        if let userId = id{
            let ref = Database.database().reference()

            ref.child("user/\(userId)/profile_image_url").setValue(imageUrl)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == (kUTTypeImage as String){
            
            
            // a photo was taken
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
                let reSizedImage = reOrientatedImage.resize()
                storeImage(image: reSizedImage)
                
            }
            
            dismiss(animated: true, completion: nil)
            
            
        } else {
            // a video option is selected
            AlertController.showAlert(self, title: "Not Available", message: "The Video Option is not available at this time")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        print("user cancelled choosing picture")
    }
    
    func infoAlert(){
        let alertUI = UIAlertController(title: "Profile Image Update", message: "Your profile image has been saved.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        alertUI.addAction(action)
        
        present(alertUI, animated: true, completion: nil)
    }
    
    
}
