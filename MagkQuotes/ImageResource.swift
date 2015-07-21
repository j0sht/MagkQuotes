//
//  ImageResource.swift
//  Magick Numbers
//
//  Created by Joshua Tate on 2015-06-27.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

enum ImageResource: String {
    
    case CaputMortuum = "Caput_mortuum"
    case EightSpokedWheel = "Eight-spoked_wheel"
    case EyeOfProvidence = "Eye_of_Providence"
    case InvertedPentagram = "Inverted_Pentagram_circumscribed"
    case SquaredCircle = "Squaredcircle"
    case SunSymbol = "Sun_symbol"
    case ErisSymbol = "Eris_symbol_2"
    
    static var names: [String] {
        return [
            ImageResource.CaputMortuum.rawValue,
            ImageResource.EightSpokedWheel.rawValue,
            ImageResource.EyeOfProvidence.rawValue,
            ImageResource.InvertedPentagram.rawValue,
            ImageResource.SquaredCircle.rawValue,
            ImageResource.SunSymbol.rawValue,
            ImageResource.ErisSymbol.rawValue
        ]
    }
    
    static var images: [UIImage] {
        return ImageResource.names.map { UIImage(named: $0)! }
    }
}