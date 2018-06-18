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

    var authUI: FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // sets up firebase pre-made auth UI
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func signInOrRegister(_ sender: UIButton) {
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
