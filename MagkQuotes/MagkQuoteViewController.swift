//
//  ViewController.swift
//  MagkQuotes
//
//  Created by Joshua Tate on 2015-07-19.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

class MagkQuoteViewController: UIViewController {
    
    private struct MagickSelectors {
        static let LongPress = Selector("longPress:")
        static let LongPressScreenShot = Selector("longPressScreenshot")
    }

    // MARK:- Properties
    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    // MARK: Private Properties
    private let Grey1 = UIColor(red: 242, green: 242, blue: 242)
    
    private var quoteCollection: QuoteCollection!
    private var currentAuthorQuotePair: (author: Author, quote: Quote)!
    
    private var longpressScreenshotTimer: NSTimer!
    
    // MARK:- UIViewController Methods
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.animationImages = ImageResource.images
        imageView.animationDuration = 0.6
        
        quoteCollection = QuoteCollection(fileName: "QuoteCollection1")
        
        introAnimation()
    }

    // MARK:- Custom Methods
    // MARK:- Gesture Recognizers
    func longPress(press: UILongPressGestureRecognizer) {
        
        if press.state == UIGestureRecognizerState.Began {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
                
                // Put expensive code here
                self.currentAuthorQuotePair = self.quoteCollection.getAuthorQuotePair()
                let quoteText = self.quoteCollection.authorQuoteString(self.currentAuthorQuotePair)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.quoteLabel.text = quoteText
                    chainedAnimationsWith(
                        duration: 0.2,
                        completion: nil,
                        animations: [
                            {
                                self.setRandomColor()
                                self.imageView.alpha = 0.0
                                self.quoteLabel.alpha = 1.0
                                
                                self.quoteLabel.transform = CGAffineTransformMakeScale(0.96, 0.96)
                            },
                            {
                                
                                self.quoteLabel.transform = CGAffineTransformMakeScale(1.02, 1.02)
                            },
                            {
                                self.quoteLabel.transform = CGAffineTransformMakeScale(1, 1)
                            }
                        ]
                    )
                }
            }
            
            longpressScreenshotTimer = NSTimer.scheduledTimerWithTimeInterval(2,
                target: self,
                selector: MagickSelectors.LongPressScreenShot,
                userInfo: nil,
                repeats: false
            )
        } else if press.state == UIGestureRecognizerState.Ended {
            if longpressScreenshotTimer.valid {
                longpressScreenshotTimer.invalidate()
                animateFadeQuote()
            }
        }
    }
    
    func longPressScreenshot() {
        let screenshot = generateScreenShot(before: nil, after: nil)
        chainedAnimationsWith(duration: 0.24,
            completion: { _ in
                self.presentAcitvityViewControllerWithScreenShot(screenshot)
            },
            animations: [
                {
                    self.heartLabel.alpha = 0.0
                    self.heartLabel.transform = CGAffineTransformMakeScale(1.4, 1.4)
                },
                {
                    self.heartLabel.alpha = 1.0
                    self.heartLabel.transform = CGAffineTransformMakeScale(0.9, 0.9)
                },
                {
                    self.heartLabel.transform = CGAffineTransformMakeScale(1, 1)
                }
            ]
        )
    }
    
    // MARK: Private Methods
    private func generateScreenShot(#before: (() -> Void)?, after: (() -> Void)?) -> UIImage {
        
        if let before = before { before() }
        
        if UIScreen.mainScreen().respondsToSelector(Selector("scale")) {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, UIScreen.mainScreen().scale)
        } else {
            UIGraphicsBeginImageContext(self.view.frame.size)
        }
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let after = after { after() }
        
        return screenshot
    }
    
    private func setRandomColor() {
        view.backgroundColor = getRandomColor()
    }
    
    private func animateFadeQuote() {
        chainedAnimationsWith(duration: 0.2,
            completion: { _ in
                self.quoteLabel.text = nil
            },
            animations: [
                {
                    self.view.backgroundColor = self.Grey1
                    self.imageView.alpha = 1.0
                    self.quoteLabel.alpha = 0.0
                }
            ]
        )
    }
    
    private func presentAcitvityViewControllerWithScreenShot(screenshot: UIImage) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            // Put expensive code here
            let authorName = self.currentAuthorQuotePair.author.hashtagName()
            let msg = "M▲GK from \(authorName)"
            let activityVC = UIActivityViewController(activityItems: [msg,screenshot], applicationActivities: nil)
            activityVC.completionWithItemsHandler = {
                (s: String!, ok: Bool, items: [AnyObject]!, err: NSError!) -> Void in
                // Where you do something when the activity view is completed.
                self.animateFadeQuote()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    private func introAnimation() {
        view.backgroundColor = Grey1
        quoteLabel.alpha = 0.0
        quoteLabel.text = nil
        imageView.alpha = 0.0
        
        let duration: NSTimeInterval = 0.33
        
        chainedAnimationsWith(duration: duration,
            completion: {_ in
                self.countdownLabel.text = "2"
                chainedAnimationsWith(duration: duration,
                    completion: {_ in
                        self.countdownLabel.text = "1"
                        chainedAnimationsWith(duration: duration,
                            completion: {_ in
                                self.countdownLabel.text = nil
                                self.countdownLabel.hidden = true
                                self.imageView.alpha = 1.0
                                self.imageView.startAnimating()
                                
                                self.initiateLongPress()
                            },
                            animations: [
                                {self.countdownLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)},
                                {self.countdownLabel.transform = CGAffineTransformMakeScale(0.8, 0.8)},
                                {self.countdownLabel.transform = CGAffineTransformMakeScale(1, 1)}
                            ]
                        )
                    },
                    animations: [
                        {self.countdownLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)},
                        {self.countdownLabel.transform = CGAffineTransformMakeScale(0.8, 0.8)},
                        {self.countdownLabel.transform = CGAffineTransformMakeScale(1, 1)}
                    ]
                )
            },
            animations: [
                {self.countdownLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)},
                {self.countdownLabel.transform = CGAffineTransformMakeScale(0.8, 0.8)},
                {self.countdownLabel.transform = CGAffineTransformMakeScale(1, 1)}
            ]
        )
    }
    
    private func initiateLongPress() {
        let longPressToPauseAnimation = UILongPressGestureRecognizer(
            target: self,
            action: MagickSelectors.LongPress
        )
        longPressToPauseAnimation.minimumPressDuration = 0.168
        self.view.addGestureRecognizer(longPressToPauseAnimation)
    }
}

