//
//  ParallaxShaderViewExtension.swift
//
//  Created by JHays on 9/21/14.
//  Copyright (c) 2014 orbosphere. All rights reserved.
//
//  From: https://goo.gl/AFvTGQ

import UIKit
import Foundation

extension UIView {
    
    func addShadow() {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2.0
        self.layer.shadowOffset = CGSizeMake(0, 1)
    }
    
    
    func addShadowParallaxMotionEffect(amount: CGFloat) {
        
        let multipliedAmount = 10.0*amount;
        
        var motionX = UIInterpolatingMotionEffect(keyPath: "layer.shadowOffset.width", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        var motionY = UIInterpolatingMotionEffect(keyPath: "later.shadowOffset.height", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        
        motionX.maximumRelativeValue = multipliedAmount
        motionX.minimumRelativeValue = -multipliedAmount
        
        motionY.maximumRelativeValue = multipliedAmount
        motionY.minimumRelativeValue = -multipliedAmount
        
        var group = UIMotionEffectGroup()
        group.motionEffects = [motionX, motionY]
        
        self.addMotionEffect(group)
    }
    
    func addParallaxMotionEffect(amount: CGFloat) {
        
        let multipliedAmount = 10.0*amount;
        
        var verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        var horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        
        verticalMotionEffect.maximumRelativeValue = multipliedAmount
        verticalMotionEffect.minimumRelativeValue = -multipliedAmount
        
        horizontalMotionEffect.maximumRelativeValue = multipliedAmount
        horizontalMotionEffect.minimumRelativeValue = -multipliedAmount
        
        var group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        self.addMotionEffect(group)
    }
    
    func addParallaxAndShadowEffects(amount: CGFloat, addShadow: Bool) {
        if addShadow { self.addShadow() }
        self.addShadowParallaxMotionEffect(amount)
        self.addParallaxMotionEffect(amount)
    }
    
}