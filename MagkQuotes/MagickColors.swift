//
//  MagickColors.swift
//  Magick Numbers
//
//  Created by Joshua Tate on 2015-07-03.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

func getRandomColor() -> UIColor {
    let min = 70
    let max = 255
    let red = randomIntBetween(min: min, max: max, inclusive: true)
    let blue = randomIntBetween(min: min, max: max, inclusive: true)
    let green = randomIntBetween(min: min, max: max, inclusive: true)
    //println("red = \(red) | green = \(green) | blue = \(blue)")
    return UIColor(red: red, green: green, blue: blue)
}