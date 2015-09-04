//
//  UIKitExtensions.swift
//  MagkQuotes
//
//  Created by Joshua Tate on 2015-07-25.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

// code from: http://goo.gl/5LGRqU
extension UILabel {
    
    func fitToAvoidWordWrapping(){
        // adjusts the font size to avoid long word to be wrapped
        
        // get text as NSString
        let text = self.text ?? "" as NSString
        
        // get array of words separate by spaces
        let words = text.componentsSeparatedByString(" ") as! [NSString]
        
        // I will need to find the largest word and its width in points
        var largestWord : NSString = ""
        var largestWordWidth : CGFloat = 0
        
        // iterate over the words to find the largest one
        for word in words{
            
            // get the width of the word given the actual font of the label
            let wordSize = word.sizeWithAttributes([NSFontAttributeName : self.font])
            let wordWidth = wordSize.width
            
            // check if this word is the largest one
            if wordWidth > largestWordWidth{
                largestWordWidth = wordWidth
                largestWord = word
            }
        }
        
        // now that I have the largest word, reduce the label's font size until it fits
        while largestWordWidth > self.bounds.width && self.font.pointSize > 1{
            
            // reduce font and update largest word's width
            self.font = self.font.fontWithSize(self.font.pointSize - 1)
            let largestWordSize = largestWord.sizeWithAttributes([NSFontAttributeName : self.font])
            largestWordWidth = largestWordSize.width
        }
    }
    
}

// MARK: Motion Effect Extentions
// code from: http://goo.gl/qGXOLB
extension UIMotionEffect {
    static func twoAxesShift(strength: Float) -> UIMotionEffect {
        
        func motion(type: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
            let keyPath = type == .TiltAlongHorizontalAxis ? "center.x" : "center.y"
            let motion = UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
            motion.minimumRelativeValue = -strength
            motion.maximumRelativeValue = strength
            return motion
        }
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [
            motion(.TiltAlongHorizontalAxis),
            motion(.TiltAlongVerticalAxis)
        ]
        return group
    }
    
    static func relativeValue(strength: Float, isMax: Bool, type: UIInterpolatingMotionEffectType) -> NSValue {
        var transform = CATransform3DIdentity
        transform.m34 = (1.0 * CGFloat(strength)) / 2000.0
        
        let axisValue: CGFloat
        if type == .TiltAlongVerticalAxis {
            // transform vertically
            axisValue = isMax ? -1.0 : 1.0
            transform = CATransform3DRotate(transform, axisValue * CGFloat(M_PI_4), 1, 0, 0)
        } else {
            // transform horizontally
            axisValue = isMax ? 1.0 : -1.0
            transform = CATransform3DRotate(transform, axisValue * CGFloat(M_PI_4), 0, 1, 0)
        }
        return NSValue(CATransform3D: transform)
    }
    
    static func twoAxesTilt(strength: Float) -> UIMotionEffect {
//        func relativeValue(isMax: Bool, type: UIInterpolatingMotionEffectType) -> NSValue {
//            var transform = CATransform3DIdentity
//            transform.m34 = (1.0 * CGFloat(strength)) / 2000.0
//            
//            let axisValue: CGFloat
//            if type == .TiltAlongVerticalAxis {
//                // transform vertically
//                axisValue = isMax ? -1.0 : 1.0
//                transform = CATransform3DRotate(transform, axisValue * CGFloat(M_PI_4), 1, 0, 0)
//            } else {
//                // transform horizontally
//                axisValue = isMax ? 1.0 : -1.0
//                transform = CATransform3DRotate(transform, axisValue * CGFloat(M_PI_4), 0, 1, 0)
//            }
//            return NSValue(CATransform3D: transform)
//        }
        
        // create motion for specified `type`.
        func motion(theType: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
            let motion = UIInterpolatingMotionEffect(keyPath: "layer.transform", type: theType)
            motion.minimumRelativeValue = relativeValue(strength, isMax: false, type: theType)
            motion.maximumRelativeValue = relativeValue(strength, isMax: true, type: theType)
            return motion
        }
        
        // create group of horizontal and vertical tilt motions
        let group = UIMotionEffectGroup()
        group.motionEffects = [
            motion(.TiltAlongHorizontalAxis),
            motion(.TiltAlongVerticalAxis)
        ]
        return group
    }
}