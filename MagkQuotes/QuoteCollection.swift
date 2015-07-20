//
//  QuoteCollections.swift
//  PlistReader
//
//  Created by Joshua Tate on 2015-07-14.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import Foundation

struct QuoteCollection: Printable {
    
    private(set)var authors: [Author] = []
    private var authorQuotePairs: [(author: Author, quote: Quote)]!
    
    init(fileName: String) {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) {
                for item in array {
                    if let collection = item as? [String:[[String:String]]] {
                        let authorsArray = collection.keys.array
                        for author in authorsArray {
                            let quoteCollectionArrayForAuthor = collection[author]!
                            var quotes: [Quote] = []
                            for quoteProperties in quoteCollectionArrayForAuthor {
                                let theQuote = quoteProperties["quote"]!
                                var quote = Quote(quote: theQuote)
                                if let source = quoteProperties["source"] {
                                    quote.source = source
                                }
                                if let date = quoteProperties["year"] {
                                    quote.date = date
                                }
                                quotes.append(quote)
                            }
                            let authorAndQuotes = Author(name: author, quotes: quotes)
                            authors.append(authorAndQuotes)
                        }
                    }
                }
            }
        }
        authorQuotePairs = generateAuthorQuotePairList()
    }
    
    var description: String {
        return "\(authors)"
    }
    
    func getRandomAuthor() -> Author? {
        if !authors.isEmpty {
            let index = Int(arc4random_uniform(UInt32(authors.count)))
            return authors[index]
        }
        return nil
    }
    
    func generateAuthorQuotePairList() -> [(author: Author, quote: Quote)] {
        var result:[(author: Author, quote: Quote)] = []
        
        for author in authors {
            var authorsQuotes: [(author: Author, quote: Quote)] = []
            for quote in author.quotes {
                authorsQuotes.append((author: author,quote: quote))
            }
            result += authorsQuotes
        }
        
        result.shuffle()
        return result
    }
    
    mutating func getAuthorQuotePair() -> (author: Author, quote: Quote) {
        if authorQuotePairs.isEmpty {
            authorQuotePairs = generateAuthorQuotePairList()
        }
        return authorQuotePairs.removeLast()
    }
    
    func authorQuoteString(authorQuotePair: (author: Author, quote: Quote)) -> String {
        let quote = authorQuotePair.quote.quote
        let authorName = authorQuotePair.author.name
        return "\"\(quote)\"" + "\n\n- " + authorName
    }
}