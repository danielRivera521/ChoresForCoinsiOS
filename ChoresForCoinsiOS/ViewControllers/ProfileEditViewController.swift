import UIKit
import Firebase
import FirebaseUI
import MessageUI

class ProfileEditViewController: UIViewController, FUIAuthDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var parentKeyLabelSmall: UILabel!
    @IBOutlet weak var parentKeyLabel: UILabel!
    @IBOutlet weak var parentKeyTextField: UITextField!
    @IBOutlet weak var profilePicButton: UIButton!
    @IBOutlet weak var updateProfilePicView: UIView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var sentParentKeyButton: UIButton!
    
    var authUI: FUIAuth?
    var email: String?
    var parentKey: String?
    var username: String?
    var isParent: Bool?
    var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBackground()
        
        isFirstLoad = false
        
        // get current user
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            email = user.email
            
            // get user data from database
            Database.database().reference().child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let val = snapshot.value as? [String:Any] {
                    if let userParent = val["user_parent"] as? Bool {
                        if !userParent {
                            self.sentParentKeyButton.isHidden = true
                        }
                    }
                    
                    if let usernameUnwrapped = val["user_name"] as? String {
                        self.username = usernameUnwrapped
                        self.usernameTextField.text = usernameUnwrapped
                    }
                    
                    // get parent key
                    if let parentKeyUnwrapped = val["parent_id"] as? String {
                        self.parentKey = parentKeyUnwrapped
                        self.parentKeyLabel.text = parentKeyUnwrapped
                    }
                    
                    self.getPhoto()
                }
            }
        }
        
        if let emailUnwrapped = email {
            emailTextField.text = emailUnwrapped
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isFirstLoad {
            getPhoto()
        }
        isFirstLoad = false
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
    
    @IBAction func toGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIButton) {
        let ref = Database.database().reference()
        
        // gather text from text fields and save to current user object and database
        if Auth.auth().currentUser != nil {
            // set uid with unwrapped optional (trying to avoid issues with firebase and optionals)
            var uid = ""
            if let actualID = Auth.auth().currentUser?.uid {
                uid = actualID
            }
            
            _ = saveUsername(ref: ref, uid: uid)
            _ = saveEmail(ref: ref, uid: uid)
            
            // alert user that chore was saved
            let alert = UIAlertController(title: "Success", message: "Profile Changes Saved", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func saveUsername(ref: DatabaseReference, uid: String) -> Bool {
        // check that the text field value is not empty or whitespaces
        guard let _ = usernameTextField.text, !usernameTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty else {
            // alert user something went wrong
            AlertController.showAlert(self, title: "Warning", message: "Please enter something for Username")
            return false
        }
        
        // check if values don't match
        if username != usernameTextField.text! {
            var displayNameSuccess = true
            
            // update display name as well
            let user = Auth.auth().currentUser?.createProfileChangeRequest()
            user?.displayName = username
            user?.commitChanges(completion: { (error) in
                if let error = error {
                    displayNameSuccess = false
                    print(error.localizedDescription)
                    // alert user something went wrong
                    AlertController.showAlert(self, title: "Error", message: "Username was not saved")
                }
            })
            
            if displayNameSuccess {
                // save data to database
                ref.child("user/\(uid)/user_name").setValue(usernameTextField.text!)
                
                return true
            }
        }
        
        return false
    }
    
    func saveEmail(ref: DatabaseReference, uid: String) -> Bool {
        // check that the text field value is not empty or whitespaces
        guard let _ = emailTextField.text, !emailTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty else {
            // alert user something went wrong
            AlertController.showAlert(self, title: "Warning", message: "Please enter something for Email")
            return false
        }
        
        // make sure email is correct format
        guard let _ = emailTextField.text, isValidEmail(email: emailTextField.text!) else {
            AlertController.showAlert(self, title: "Warning", message: "The email address is in an incorrect format.")
            return false
        }
        
        // check if values don't match
        if email != emailTextField.text! {
            
            // update email on firebase
            Auth.auth().currentUser?.updateEmail(to: emailTextField.text!, completion: { (error) in
                if let error = error {
                    print(error)
                    AlertController.showAlert(self, title: "Error", message: "There was an error saving your new email. Please try again")
                    return
                }

                
            })
            let emailAlert = UIAlertController(title: "Email Changed", message: "Email successfully changed. You will be logged out. Please log back into the application with your updated email account.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                
                do{
                    // sign out
                    try self.authUI?.signOut()
                    //self.performSegue(withIdentifier: "goToAuth", sender: self)
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                catch {
                    //handle error
                    print("Error in signout after email change")
                }
            }
            
            emailAlert.addAction(okAction)
            present(emailAlert, animated: true, completion: nil)
           
        }
        
        return false
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
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
                        
                        self.profilePicButton.setBackgroundImage(image, for: .normal)
                    })
//                    self.profilePicButton.loadImagesUsingCacheWithUrlString(urlString: profileURL, inViewController: self)
                    //turn button into a circle
                    self.profilePicButton.layer.cornerRadius = self.profilePicButton.frame.width/2
                    self.profilePicButton.layer.masksToBounds = true
                }
            }
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            AlertController.showAlert(self, title: "Error", message: "The email was not able to send. Please try again.")
            print("Mail compose failed with error: \(error)")
        }
        
        AlertController.showAlert(self, title: "Email Sent", message: "Your email will be sent!")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updatePassword(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: self.email!) { (error) in
            if let error = error {
                print(error.localizedDescription)
                AlertController.showAlert(self, title: "Warning", message: "There was an error in resetting your password.")
                return
            }
            
            AlertController.showAlert(self, title: "Alert", message: "An email was sent to reset your password.")
        }
    }
    
    @IBAction func sendParentKey(_ sender: UIButton) {
        // send email to someone with parent id included
        if MFMailComposeViewController.canSendMail() {
            let mailCompose = MFMailComposeViewController()
            
            if let parentid = parentKey {
                if let user = username {
                    mailCompose.setSubject("\(user) is sending you a Parent Key for the Chores for Coins application!")
                    mailCompose.setMessageBody("Hello! \(user) is sending you a Parent Key for the Chores for Coins application!\nYour Parent Key is: \(parentid).\n In the application tap on your user picture in the top left corner to go to the profile edit page. From there, you can enter this Parent Key and have you app link up with your parent's account.\n\nThanks for using Chores for Coins!", isHTML: false)
                } else {
                    mailCompose.setSubject("Parent Key for the Chores for Coins application!")
                    mailCompose.setMessageBody("Hello! Your Parent Key is: \(parentid).\n In the application tap on your user picture in the top left corner to go to the profile edit page. From there, you can enter this Parent Key and have you app link up with your parent's account.\n\nThanks for using Chores for Coins!", isHTML: false)
                }
                
                mailCompose.mailComposeDelegate = self
                
                present(mailCompose, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        do {
            // sign out
            try authUI?.signOut()
            //self.performSegue(withIdentifier: "goToAuth", sender: self)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } catch {
            // handle error
        }
    }
    
}
