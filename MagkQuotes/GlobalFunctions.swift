//
//  GlobalFunctions.swift
//  Magick Numbers
//
//  Created by Joshua Tate on 2015-07-01.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

// MARK:- Extensions
extension Array {
    var headAndTail: (head: Element, tail: [Element])? {
        return count > 0 ? (self[0], Array(self[1..<count])) : nil
    }
}

extension Array {
    func randomElement() -> Element {
        let index = Int.randomInt(self.count)
        return self[index]
    }
}

extension MutableCollectionType where Index == Int {
    mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

extension Int {
    static func randomInt(i: Int) -> Int {
        return Int(arc4random_uniform(UInt32(i)))
    }
    
    static func randomIntBetween(min: Int, and max: Int, inclusive: Bool) -> Int {
        let theMin = UInt32(min)
        let theMax = (inclusive) ? UInt32(max + 1) : UInt32(max)
        return Int(theMin + arc4random_uniform(theMax - theMin))
    }
}

extension String {
    func removeTrailingWhiteSpace() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

// MARK:- Global Functions
func chainedAnimationsWith(duration duration: NSTimeInterval, completion: (Bool -> Void)?, animations: [(() -> Void)]) {
    let headAndTail = animations.headAndTail
    switch headAndTail {
    case .Some(let head, let tail) where tail.isEmpty:
        return UIView.animateWithDuration(duration, animations: head, completion: completion)
    case .Some(let head, let tail):
        return UIView.animateWithDuration(duration,
                    animations: head,
                    completion: { _ in
                        chainedAnimationsWith(
                            duration: duration,
                            completion: completion,
                            animations: tail
                        )
                })
    default: return
    }
}