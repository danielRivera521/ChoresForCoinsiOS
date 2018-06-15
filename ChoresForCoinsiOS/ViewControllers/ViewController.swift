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


class ViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    
    @IBOutlet weak var facebookLogin: FBSDKLoginButton!
    
    
    var currentUser: String?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //sets facebook button delegate
        facebookLogin.delegate = self
        facebookLogin.readPermissions = ["email"]
        
        
    }
    //
    //    //creating the Google sign in button
    //    fileprivate func configureGoogleSignInButton() {
    //        let googleSignInButton = GIDSignInButton()
    //        googleSignInButton.frame = CGRect(x: 120, y: 200, width: view.frame.width - 240, height: 50)
    //        view.addSubview(googleSignInButton)
    //        GIDSignIn.sharedInstance().uiDelegate = self as GIDSignInUIDelegate
    //    }
    
    // google login button
    @IBAction func googleLoginBtn(_ sender: UIButton) {
        GIDSignIn.sharedInstance().uiDelegate = self as GIDSignInUIDelegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error == nil {
            print("User just logged in via Facebook")
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
                if (error != nil) {
                    print("Facebook authentication failed")
                    print("\(error?.localizedDescription ?? "Facebook Error")")
                    
                    //log out of facebook due to error
                    let loginManager = FBSDKLoginManager()
                    loginManager.logOut()
                    
                } else {
                    print("Facebook authentication succeed")
                    self.fetchProfile()
                }
            }
        } else {
            print("An error occured the user couldn't log in")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print ("User logged out")
    }
    
    func fetchProfile(){
        print ("fetch profile")
        
        let parameters = ["fields": "email, first_name, last_name, picture.type(small)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            if let error = error{
                print (error)
                return
            }
            
            let dict = result as! [String : AnyObject]
            
            if let picture = dict["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String{
                print(url)
            }
            
        }
    }
    
}
