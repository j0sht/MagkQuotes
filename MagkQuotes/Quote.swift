//
//  Quote.swift
//  PlistReader
//
//  Created by Joshua Tate on 2015-07-14.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import Foundation

struct Quote: Printable {
    
    let quote: String
    var source: String?
    var date: String?
    
    init(quote: String) {
        self.quote = quote.removeTrailingWhiteSpace()
    }
    
    var description: String {
        if let source = source, let date = date {
            return "<Quote: \(quote); Source: \(source); Date: \(date)>"
        }
        return "<Quote: \(quote)>"
    }
}