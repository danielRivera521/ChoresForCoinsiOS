//
//  CustomAuthUI.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 7/6/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation
import FirebaseUI

class CustomAuthUI: FUIAuthPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView.image = #imageLiteral(resourceName: "logo_L")
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        view.insertSubview(imageView, at: 0)
    }
}
