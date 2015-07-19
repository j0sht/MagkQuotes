//
//  QuoteCollection.swift
//  PlistReader
//
//  Created by Joshua Tate on 2015-07-14.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import Foundation

struct Author: Printable {
    
    let name: String
    let quotes: [Quote]
    
    init(name: String, quotes: [Quote]) {
        self.name = name
        self.quotes = quotes
    }
    
    var description: String {
        return "Author: \(name); Quotes: \(quotes)"
    }
    
    func getRandomQuote() -> Quote {
        let index = Int(arc4random_uniform(UInt32(quotes.count)))
        return quotes[index]
    }
    
}