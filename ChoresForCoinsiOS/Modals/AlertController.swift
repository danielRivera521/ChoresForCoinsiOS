//
//  AlertController.swift
//  ChoresForCoinsiOS
//
//  Created by Daniel Rivera on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class AlertController{
    //use this to call a simple alert for any error messages.
    static func showAlert(_ inViewController: UIViewController,title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        inViewController.present(alert, animated: true, completion: nil)
    }
}
