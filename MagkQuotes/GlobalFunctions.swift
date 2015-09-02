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
    var headAndTail: (head: T, tail: [T])? {
        return count > 0 ? (self[0], Array(self[1..<count])) : nil
    }
}

extension Array {
    mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

extension Int {
    static func randomInt(i: Int) -> Int {
        return Int(arc4random_uniform(UInt32(i)))
    }
}

// MARK:- Global Functions
func chainedAnimationsWith(#duration: NSTimeInterval, #completion: (Bool -> Void)?, #animations: [(() -> Void)]) {
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

func randomIntBetween(#min: Int, #max: Int, #inclusive: Bool) -> Int {
    let theMin = UInt32(min)
    let theMax = (inclusive) ? UInt32(max + 1) : UInt32(max)
    return Int(theMin + arc4random_uniform(theMax - theMin))
}