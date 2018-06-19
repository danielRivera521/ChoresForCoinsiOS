//
//  MyFirebaseClass.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/15/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


class MyFirebaseClass {
    
    static let shared = MyFirebaseClass()
    
    var currentUser: User?
    var userId: String = ""
    var dbRef: DatabaseReference! = Database.database().reference()
    
    private var listenerhandler: AuthStateDidChangeListenerHandle?
    
    private init(){
        
    }
    
    func addUserListener(loggedIn: Bool){
        
        listenerhandler = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                //we are logged out
                self.currentUser = nil
                self.userId = ""
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    if loggedIn {
                        self.moveToMainScreen()
                    } else {
                        self.moveToLoginScreen()
                    }
                })
                
            } else {
                self.currentUser = user
                self.userId = (user?.uid)!
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.moveToMainScreen()
                }
            }
        })
    }
    
    func removeUserListener(){
        guard listenerhandler != nil  else{
            return
        }
        Auth.auth().removeStateDidChangeListener(listenerhandler!)
    }
    
    
    func isLoggedIn() -> Bool{
        return (currentUser != nil)
    }
    
    func linkedCredential(credential: AuthCredential){
        currentUser?.linkAndRetrieveData(with: credential, completion: { (user, error) in
            if let error = error {
                print(error)
                return
            }
        })
    }
    
    func logOut(){
        try! Auth.auth().signOut()
    }
    
    
    func moveToMainScreen(){
        
    }
    
    func moveToLoginScreen(){
        
    }
}

