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
        self.wiki = NSURL(string: wiki)
    }
    
    var description: String {
        return "Author: \(name); Quotes: \(quotes)"
    }
    
    func getRandomQuote() -> Quote {
        return quotes.randomElement()
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