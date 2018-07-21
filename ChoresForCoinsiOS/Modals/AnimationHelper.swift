//
//  AnimationHelper.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 7/21/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import Foundation
import UIKit

class AnimationHelper {
    
    static func createRedeemAnim(vc: UIViewController) -> UIImageView {
        
        // array of animation frames
        var redeemAnim: [UIImage] = []
        
        // rectangle boundaries of new animView
        let rect = CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height)
        
        // view that will hold the animation
        let animView = UIImageView(frame: rect)
        
        animView.contentMode = .scaleAspectFit
        
        // creates an array of all the frames of the animation
        for i in 0...68 {
            if i < 10 {
                redeemAnim.append(UIImage(named: "anim_redeem_00\(i)")!)
            } else {
                redeemAnim.append(UIImage(named: "anim_redeem_0\(i)")!)
            }
        }
        
        animView.image = redeemAnim.last
        
        // set the image view to hold the animation
        animView.animationImages = redeemAnim
        
        return animView
        
    }

    static func startAnimation(vc: UIViewController, animView: UIImageView) {
        
        // add anim view to view controller
        vc.view.addSubview(animView)
        
        animView.animationDuration = 6
        animView.animationRepeatCount = 1
        
        // start playing the animation
        animView.startAnimatingWithCompletionBlock {
            animView.removeFromSuperview()
        }

    }
}
