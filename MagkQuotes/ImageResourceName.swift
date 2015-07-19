//
//  ImageResource.swift
//  Magick Numbers
//
//  Created by Joshua Tate on 2015-06-27.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

enum ImageResourceName: String {
    
    case CaputMortuum = "Caput_mortuum"
    case ChaosStar = "Chaos_star"
    case CrossedCircle = "Crossed_circle"
    case EightSpokedWheel = "Eight-spoked_wheel"
    case EyeOfProvidence = "Eye_of_Providence"
    case InvertedPentagram = "Inverted_Pentagram_circumscribed"
    case SquaredCircle = "Squaredcircle"
    case SunSymbol = "Sun_symbol"
    case ErisSymbol = "Eris_symbol_2"
    
    static var names: [String] {
        return [
            ImageResourceName.EyeOfProvidence.rawValue,
            ImageResourceName.SquaredCircle.rawValue,
            ImageResourceName.InvertedPentagram.rawValue,
            ImageResourceName.EightSpokedWheel.rawValue,
            ImageResourceName.CrossedCircle.rawValue,
            ImageResourceName.CaputMortuum.rawValue,
            ImageResourceName.SunSymbol.rawValue,
            ImageResourceName.ChaosStar.rawValue,
        ]
    }
    
    static var images: [UIImage] {
        return ImageResourceName.names.map { UIImage(named: $0)! }
    }
}