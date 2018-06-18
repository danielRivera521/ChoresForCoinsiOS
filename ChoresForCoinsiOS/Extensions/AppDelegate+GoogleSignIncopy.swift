//
//  AppDelegate+GoogleSignIn.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/12/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

extension AppDelegate: GIDSignInDelegate {
    
    // Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            print("An error occured during Google Authentication")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if (error) != nil {
                print("Google Authentification Fail")
            } else {
                print("Google Authentification Success")
                
//                let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
//                let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "overviewVC") as! OverviewViewController
//                let appDelegate = UIApplication.shared.delegate
//                appDelegate?.window??.rootViewController = protectedPage
            }
        }
        
    }
    
    
}
