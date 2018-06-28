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
    
    var choreId: String?
    var coinValue = 0
    
    private var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //edit header information
        let name = Auth.auth().currentUser?.displayName
        if let username = name {
            usernameLabel.text = username
            getRunningTotal()
        }
        
        // get photo for profile button
        getPhoto()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePictureBtn(_ sender: UIButton) {
        
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        AlertController.showAlert(self, title: "No Picture Selected", message: "Please take an Image with your camera of the completed chore to complete this chore.")
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
    
}
