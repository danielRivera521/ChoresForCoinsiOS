//
//  ViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/15/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseStorage
import FBSDKCoreKit
import FBSDKLoginKit
import KeychainSwift


class ViewController: UIViewController, GIDSignInUIDelegate { //, FBSDKLoginButtonDelegate
    
    var databaseRef: DatabaseReference!
    @IBOutlet weak var facebookLogin: FBSDKLoginButton!
    
    var currentUser: String?
    var overviewVC: OverviewViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //sets facebook button delegate
//         facebookLogin.delegate = self
//         facebookLogin.readPermissions = ["email"]
        
        //sets the database reference to the 'user' child segment
        databaseRef = Database.database().reference().child("user")
    }
    override func viewDidAppear(_ animated: Bool) {
        //if the user already signed into application then the uid is used to access the app and bypasses the signin page.
        let keyChain = DataService().keyChain
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "overviewVC", sender: nil)
        }
    }
    
    func CompleteSignIn(id: String){
        //assigns uid to keychain
        let keyChain = DataService().keyChain
        keyChain.set(id, forKey: "uid")
    }
    
      //creating the Google sign in button
        fileprivate func configureGoogleSignInButton() {
            let googleSignInButton = GIDSignInButton()
            googleSignInButton.frame = CGRect(x: 120, y: 200, width: view.frame.width - 240, height: 50)
            view.addSubview(googleSignInButton)
            GIDSignIn.sharedInstance().uiDelegate = self as GIDSignInUIDelegate
        }
    
    //google login button
    @IBAction func googleLoginBtn(_ sender: UIButton) {
      
        GIDSignIn.sharedInstance().uiDelegate = self as GIDSignInUIDelegate
        GIDSignIn.sharedInstance().signIn()
        CompleteSignIn(id: (Auth.auth().currentUser?.uid)!)
    }
    
    @IBAction func toTabBarController(_ sender: UIButton) {
        // dismiss back to tab bar controller
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//
//        if error == nil {
//            print("User just logged in via Facebook")
//            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//            Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
//                if (error != nil) {
//                    print("Facebook authentication failed")
//                    print("\(error?.localizedDescription ?? "Facebook Error")")
//
//                    //log out of facebook due to error
//                    let loginManager = FBSDKLoginManager()
//                    loginManager.logOut()
//
//                } else {
//                    print("Facebook authentication succeed")
//                    self.fetchProfile()
//                    self.CompleteSignIn(id: (Auth.auth().currentUser?.uid)!)
//                }
//            }
//        } else {
//            print("An error occured the user couldn't log in")
//        }
//    }
    
//    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//
//        print ("User logged out")
//    }
//
//    func fetchProfile(){
//        print ("fetch profile")
//
//        let parameters = ["fields": "email, first_name, last_name, picture.type(small)"]
//        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
//            if let error = error{
//                print (error)
//                return
//            }
//
//            let dict = result as! [String : AnyObject]
//
//            if let picture = dict["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String{
//                print(url)
//            }
//
//        }
//    }
//
//    func createParentID() -> String{
//
//        var generatedID = ""
//
//        if let email = Auth.auth().currentUser?.email{
//
//            if let name = email.components(separatedBy: CharacterSet(charactersIn: ("@0123456789"))).first {
//
//                if let uid = Auth.auth().currentUser?.uid{
//                    let last5 = uid.suffix(5)
//                    generatedID = name + last5
//                }
//            }
//        }
//
//        return generatedID
//    }
//
//    func checkDatabase() {
//        if let uid = Auth.auth().currentUser?.uid {
//
//            databaseRef.observe(DataEventType.value) { (snapshot) in
//
//                for users in snapshot.children.allObjects as! [DataSnapshot]{
//                    let userObject = users.value as? [String : AnyObject]
//                    let userID = userObject?["user_id"] as! String
//
//                    if userID == uid {
//                        // user is in database
//                    } else {
//                        // register user
//                    }
//                }
//
//
//            }
//        }
//
//    }
    
}
