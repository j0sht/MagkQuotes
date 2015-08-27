//
//  QuoteCollections.swift
//  PlistReader
//
//  Created by Joshua Tate on 2015-07-14.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import Foundation

class QuoteCollection: Printable {
    
    private(set)var authors: [Author] = []
    private var authorQuotePairs: [(author: Author, quote: Quote)]!
    
    init(fileName: String) {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")!
        let array = NSArray(contentsOfFile: path)!
        for item in array {
            let authorProperties = item as! [String:AnyObject]
            let name = authorProperties["name"] as! String
            let wiki = authorProperties["wiki"] as! String
            let rawQuotes = authorProperties["quotes"] as! [String]
            let quotes = rawQuotes.map { return Quote(quote: $0) }
            let author = Author(name: name, wiki: wiki, quotes: quotes)
            authors.append(author)
        }
        authorQuotePairs = generateAuthorQuotePairList()
        printStats()
    }
    
    var description: String {
        return "\(authors)"
    }
    
    var quoteCount: Int {
        return authorQuotePairs.count
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
            result += author.authorQuotePairs()
        }
        
        result.shuffle()
        return result
    }
    
    func getAuthorQuotePair() -> (author: Author, quote: Quote) {
        if authorQuotePairs.isEmpty {
            authorQuotePairs = generateAuthorQuotePairList()
        }
        return authorQuotePairs.removeLast()
    }
    
    func authorQuoteString(authorQuotePair: (author: Author, quote: Quote)) -> String {
        let quote = authorQuotePair.quote.quote
        let authorName = authorQuotePair.author.name
        return "\"\(quote)\"" + "\n\n-" + authorName
    }
    
    func shufflePairs() {
        authorQuotePairs.shuffle()
    }
    
    private func printStats() {
        let quoteCount = authorQuotePairs.count
        let authorCount = authors.count
        println("Number of author-quote pairs: \(quoteCount)")
        println("Number of quotes per author: \(Double(quoteCount) / Double(authorCount))")
    }
}