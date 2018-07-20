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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: nibBundleOrNil, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView.image = #imageLiteral(resourceName: "logoSplash")
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        view.insertSubview(imageView, at: 0)
    }
}
