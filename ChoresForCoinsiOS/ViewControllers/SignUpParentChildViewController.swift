//
//  SignUpParentChildViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class SignUpParentChildViewController: UIViewController, FUIAuthDelegate {

    @IBOutlet weak var bgImage: UIImageView!
    
    var authUI: FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setRootViewController()
        
        // sets up firebase pre-made auth UI
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
//            FUIFacebookAuth()
        ]
        self.authUI?.providers = providers
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // this is called after a sign in attempt is made
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let userStatus = authDataResult?.additionalUserInfo?.isNewUser {
            if error == nil && userStatus {
                // go to parent child page
                performSegue(withIdentifier: "goToParentChild", sender: self)
            } else if error == nil {
                // go to overview page
                performSegue(withIdentifier: "goToOverview", sender: self)
            }
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {

        let customAuthUI = CustomAuthUI(authUI: authUI)

        return customAuthUI
    }
    
    // persistent login check
    func setRootViewController() {
        // if someone is logged in, go to the overview page
        if Auth.auth().currentUser != nil {
            // go to overview page
            performSegue(withIdentifier: "goToOverview", sender: self)
        }
    }
    
    func getBackground() {
        var userID = ""
        
        if let uid = Auth.auth().currentUser?.uid {
            userID = uid
        }
        
        Database.database().reference().child("user/\(userID)/bg_image").observeSingleEvent(of: .value) { (snapshot) in
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
    
    @IBAction func signInOrRegister(_ sender: UIButton) {
//        if let authui = authUI {
//            let authVC = CustomAuthUI(authUI: authui)
//            present(authVC, animated: true, completion: nil)
//        }
        
        // present pre-made Auth UI
        if let authVC = authUI?.authViewController() {
            present(authVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func skipRegistration(_ sender: UIButton) {
        Auth.auth().signInAnonymously { (authResult, error) in
            self.performSegue(withIdentifier: "goToOverview", sender: self)
        }
    }
}
