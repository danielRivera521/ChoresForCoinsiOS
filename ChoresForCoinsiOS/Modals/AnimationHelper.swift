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
        for i in 0...149 {
            if i < 10 {
                redeemAnim.append(UIImage(named: "anim_redeem_00\(i)")!)
            } else if i < 100 {
                redeemAnim.append(UIImage(named: "anim_redeem_0\(i)")!)
            } else {
                redeemAnim.append(UIImage(named: "anim_redeem_\(i)")!)
            }
        }
        
        animView.image = redeemAnim.last
        
        // set the image view to hold the animation
        animView.animationImages = redeemAnim
        
        return animView
        
    }
    
    static func createCoinsEarnedAnim(vc: UIViewController) -> UIImageView {
        
        // array of animation frames
        var coinAnim: [UIImage] = []
        
        // rectangle boundaries of new animView
        let rect = CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height)
        
        // view that will hold the animation
        let animView = UIImageView(frame: rect)
        
        animView.contentMode = .scaleAspectFit
        
        // creates an array of all the frames of the animation
        for i in 0...119 {
            if i < 10 {
                coinAnim.append(UIImage(named: "anim_coin_add_00\(i)")!)
            }  else if i < 100 {
                coinAnim.append(UIImage(named: "anim_coin_add_0\(i)")!)
            } else {
                coinAnim.append(UIImage(named: "anim_coin_add_\(i)")!)
            }
        }
        
        animView.image = coinAnim.last
        
        // set the image view to hold the animation
        animView.animationImages = coinAnim
        
        return animView
        
    }

    static func startAnimation(vc: UIViewController, animView: UIImageView, anim: Int) {
        
        // add anim view to view controller
        vc.view.addSubview(animView)
        
        // 0 = redeem anim, 1 = coin earned anim
        if anim == 0 {
            animView.animationDuration = 2.5
            animView.animationRepeatCount = 1
            
            // start playing the animation
            animView.startAnimatingWithCompletionBlock {
                animView.removeFromSuperview()
            }
        } else {
            animView.animationDuration = 2
            animView.animationRepeatCount = 1
            
            // start playing the animation
            animView.startAnimatingWithCompletionBlock {
                vc.dismiss(animated: true, completion: nil)
            }
        }
    }
}
