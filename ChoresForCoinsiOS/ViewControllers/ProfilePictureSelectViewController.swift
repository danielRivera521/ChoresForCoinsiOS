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
    
    private var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func doGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectProfilePic(_ sender: UIButton) {
        // send selected pic back to previous page
        // will have to know if came from account creation page or profile edit page
    }
    
    @IBAction func takeProfilePic(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // if the device's camera is functioning and available, set imagePickers source as the camera
        // if not, use photo library instead
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        // lets user edit photos taken with camera or in photo library
        imagePicker.allowsEditing = true
        // sets the media type to the same as the camera or photo library
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
        
        // present the image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let ref = Database.database().reference()
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == (kUTTypeImage as String) {
            // a photo was taken
            // save photo to firebase storage
            var userID = ""
            if let userid = Auth.auth().currentUser?.uid {
                userID = userid
                let range = userID.index(userID.startIndex, offsetBy: 5)..<userID.endIndex
                userID.removeSubrange(range)
                let filename = "\(userID)ProfilePicture.png"
                let fileref = Storage.storage().reference().child(filename)
                let meta = StorageMetadata()
                meta.contentType = "image/png"
                
                if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    fileref.putData(UIImagePNGRepresentation(img)!, metadata: meta, completion: { (meta, error) in
                        if error == nil {
                            ref.child("user/\(userid)/profilePicture").setValue(filename)
                        } else {
                            print(error?.localizedDescription)
                            AlertController.showAlert(self, title: "Alert", message: "Picture was not able to be saved.")
                        }
                    })
                }
            }
            
            dismiss(animated: true) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        print("user cancelled choosing picture")
    }
    
    
}
