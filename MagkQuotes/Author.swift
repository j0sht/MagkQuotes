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
    var wiki: NSURL?
    let quotes: [Quote]
    
    init(name: String, wiki: String, quotes: [Quote]) {
        self.name = name
        self.quotes = quotes
        
        if let wikiURL = NSURL(fileURLWithPath: wiki) {
            self.wiki = wikiURL
        }
    }
    
    var description: String {
        return "Author: \(name); Quotes: \(quotes)"
    }
    
    func getRandomQuote() -> Quote {
        let index = Int(arc4random_uniform(UInt32(quotes.count)))
        return quotes[index]
    }
    
    func hashtagName() -> String {
        let punctuation = [".","-"]
        var result = ""
        for char in name {
            if contains(punctuation, String(char)) {
                continue
            }
            result += String(char)
        }
        result = join("", result.componentsSeparatedByString(" "))
        return "#" + result
    }
    
    func authorQuotePairs() -> [(author: Author, quote: Quote)] {
        return quotes.map { return (self, $0) }
    }
}