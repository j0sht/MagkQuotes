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