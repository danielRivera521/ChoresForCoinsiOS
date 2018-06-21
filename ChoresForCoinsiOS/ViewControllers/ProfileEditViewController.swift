import UIKit
import Firebase
import FirebaseUI

class ProfileEditViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var parentKeyLabelSmall: UILabel!
    @IBOutlet weak var parentKeyLabel: UILabel!
    @IBOutlet weak var parentKeyTextField: UITextField!
    
    var authUI: FUIAuth?
    var ref: DatabaseReference?
    
    var uid: String?
    var email: String?
    var parentKey: String?
    var username: String?
    var isParent: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // get a reference of the database from Firebase
//        ref = Database.database().reference()
//
//        // get current user
//        let user = Auth.auth().currentUser
//        if let user = user {
//            uid = user.uid
//            email = user.email
//
//            // get user data from database
//            ref?.child("user").child(uid!).observe(.value, with: { (snapshot) in
//                if let val = snapshot.value as? [String:Any] {
//                    if let usernameUnwrapped = val["user_name"] as? String {
//                        self.username = usernameUnwrapped
//                        self.usernameTextField.text = usernameUnwrapped
//                    }
//
//                    // get parent key
//                    if let parentKeyUnwrapped = val["parent_key"] as? String {
//                        self.parentKey = parentKeyUnwrapped
//
//                        // get isParent
//                        if let isParentUnwrapped = val["user_parent"] as? Bool {
//                            self.isParent = isParentUnwrapped
//
//                            // check if user is parent. Turn on/off text fields accordingly
//                            if isParentUnwrapped {
//                                // for parent
//                                self.parentKeyLabel.isHidden = false
//                                self.parentKeyTextField.isHidden = true
//
//                                // set parentkey in label
//                                if let parentKeyUnwrapped = self.parentKey {
//                                    self.parentKeyLabel.text = parentKeyUnwrapped
//                                }
//                            } else {
//                                // for child
//                                self.parentKeyLabel.isHidden = true
//                                self.parentKeyTextField.isHidden = false
//
//                                // set parentkey in text field
//                                if let parentKeyUnwrapped = self.parentKey {
//                                    self.parentKeyTextField.text = parentKeyUnwrapped
//                                }
//                            }
//                        }
//                    }
//                }
//            })
//        }
//
//        if let emailUnwrapped = email {
//            emailTextField.text = emailUnwrapped
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // removeallobservers
    }
    
    @IBAction func toGoBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIButton) {
//        // gather text from text fields and save to current user object and database
//        if Auth.auth().currentUser != nil {
//
//            // if username is nil, then user hasn't entered one yet, needs to be saved on db
//            if username == nil {
//                // make sure text field ins't empty or nil
//                if usernameTextField.text != nil {
//                    // check that the text field value is not empty or whitespaces
//                    if !usernameTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
//                        // save to db
//                        ref?.child("user/\(uid!)/user_name").setValue(usernameTextField.text!)
//                    }
//                }
//                // if the username text field doesn't match, then that means the user changed it
//            } else {
//                if usernameTextField.text != nil {
//                    // check that the text field value is not empty or whitespaces
//                    if !usernameTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
//                        // check if values don't match
//                        if username != usernameTextField.text! {
//                            // save data to database
//                            ref?.child("user/\(uid!)/user_name").setValue(usernameTextField.text!)
//                        }
//                    }
//                }
//            }
//
//            // if the email text field doesn't match, then that means the user changed it
//            if email != nil && emailTextField.text != nil {
//                // check that the text field value is not empty or whitespaces
//                if !emailTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
//                    // check if values don't match
//                    if email != emailTextField.text! {
//                        // update email on firebase
//                        Auth.auth().currentUser?.updateEmail(to: emailTextField.text!, completion: { (error) in
//                            // TODO: add alert
//                            if let error = error {
//                                print(error)
//                            }
//                        })
//                    }
//                }
//            }
//
//            // PASSWORD UPDATE... may need to watch tutorial on how to properly update a password!!!!!!!!!!
//            if let newPassword = passwordTextField.text {
//                // check that the text field value is not empty or whitespaces
//                if !newPassword.trimmingCharacters(in: .whitespaces).isEmpty {
//                    Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
//                        if let error = error {
//                            print(error)
//                        }
//                    })
//                }
//            }
//
//            // if user is child, check for change in parent key text field. Update firebase and object
//            if let isParent = isParent {
//                if !isParent {
//                    if parentKey == nil {
//                        if parentKeyTextField.text != nil {
//                            if !parentKeyTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
//                                ref?.child("user/\(uid!)/parent_key").setValue(parentKeyTextField.text!)
//                            }
//                        }
//                    } else {
//                        if parentKeyTextField.text != nil {
//                            if !parentKeyTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
//                                if parentKey != parentKeyTextField.text! {
//                                    ref?.child("user/\(uid!)/parent_key").setValue(parentKeyTextField.text!)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        dismiss(animated: true, completion: nil)
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
