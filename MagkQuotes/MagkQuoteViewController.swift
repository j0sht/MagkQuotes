//
//  ViewController.swift
//  MagkQuotes
//
//  Created by Joshua Tate on 2015-07-19.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

// TODO: Fix bug related to timers, and view appearing/disappearing.
class MagkQuoteViewController: UIViewController {
    
    private struct MagickSelectors {
        static let LongPress = Selector("longPress:")
        static let LongPressScreenShot = Selector("longPressScreenshot")
        static let AnimateFadeQuote = Selector("animateFadeQuote")
        static let SwipeUp = Selector("swipeUp")
    }

    // MARK:- Properties
    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    // MARK:- Private Properties
    private let Grey1 = UIColor(red: 242, green: 242, blue: 242)
    
    private let quoteCollection = QuoteCollection(fileName: "QuoteCollection")
    private var currentAuthorQuotePair: (author: Author, quote: Quote)!
    
    private var longPressToPauseAnimation: UILongPressGestureRecognizer!
    
    private var longpressScreenshotTimer: NSTimer!
    private var screenshotTimer: NSTimer?
    
    private var pressCount = 0
    
    private var takingScreenShot = false
    private var finishedIntro = false
    
    private var fontSize: CGFloat!
    private var fontName: String!
    
    private var swipeUpToPresentWiki: UISwipeGestureRecognizer!
    var quoteSummoned = false
    
    private var timeRemainingToTakeScreenshot: NSTimeInterval = 15
    
    // MARK:- UIViewController Methods
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.animationImages = ImageResource.images
        imageView.animationDuration = 0.59
        
        fontSize = quoteLabel.font.pointSize
        fontName = quoteLabel.font.fontName
        
        swipeUpToPresentWiki = UISwipeGestureRecognizer(target: self, action: MagickSelectors.SwipeUp)
        swipeUpToPresentWiki.direction = UISwipeGestureRecognizerDirection.Up
        view.addGestureRecognizer(swipeUpToPresentWiki)
        
        introAnimation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if quoteSummoned { updateScreenShotTimer() }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        screenshotTimer?.invalidate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK:- Weird WKWebView bug - Fixed?
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let presented = self.presentedViewController {
            presented.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    // MARK:- Custom Methods
    // MARK:- Gesture Recognizers
    // MARK: Called to summon/dismiss quotes, or take screenshot.
    func longPress(press: UILongPressGestureRecognizer) {
        
        let tapToDismiss = (press.state == .Ended && pressCount > 1)
        let summonedScreenshot = (press.state == .Began && !takingScreenShot)
        
        if summonedScreenshot {
            pressCount++
            
            if pressCount < 2 {
                // MARK: Quote summoned here
                quoteSummoned = true
                screenshotTimer = NSTimer.scheduledTimerWithTimeInterval(timeRemainingToTakeScreenshot,
                    target: self,
                    selector: MagickSelectors.AnimateFadeQuote,
                    userInfo: nil,
                    repeats: false
                )
                
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
                    
                    // Put expensive code here
                    self.quoteCollection.shufflePairs()
                    self.currentAuthorQuotePair = self.quoteCollection.getAuthorQuotePair()
                    let quoteText = self.quoteCollection.authorQuoteString(self.currentAuthorQuotePair)
                    // TODO: Italicize the author name.
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quoteLabel.text = quoteText
                        self.quoteLabel.fitToAvoidWordWrapping()
                        UIView.animateWithDuration(0.12,
                            animations: {self.imageView.alpha = 0.0}) { _ in
                            chainedAnimationsWith(
                                duration: 0.22,
                                completion: nil,
                                animations: [
                                    {
                                        self.setRandomColor()
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
                }
            }
            
            if pressCount > 1 {
                // MARK: Take screenshot here
                screenshotTimer?.invalidate()
                longpressScreenshotTimer = NSTimer.scheduledTimerWithTimeInterval(0.7,
                    target: self,
                    selector: MagickSelectors.LongPressScreenShot,
                    userInfo: nil,
                    repeats: false
                )
            }
            
        } else if tapToDismiss {
            // MARK: Quote dismissed here
            if longpressScreenshotTimer.valid {
                longpressScreenshotTimer.invalidate()
                screenshotTimer?.invalidate()
                animateFadeQuote()
                pressCount = 0
            }
        }
    }
    // MARK: Called to present WikiVC
    func swipeUp() {
        if quoteSummoned {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let navVC = storyboard.instantiateViewControllerWithIdentifier("WikiNavController") as! UINavigationController
            let wikiVC = navVC.viewControllers[0] as! WikiViewController
            wikiVC.wikiURL = currentAuthorQuotePair.author.wiki
            presentViewController(navVC, animated: true, completion: nil)
        }
    }
    
    // MARK:- Screenshot and Animation
    func longPressScreenshot() {
        takingScreenShot = true
        chainedAnimationsWith(duration: 0.24,
            completion: { _ in
                let screenshot = self.generateScreenShot(before: nil, after: nil)
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
    
    func hideQuote() {
        if finishedIntro {
            view.backgroundColor = Grey1
            imageView.alpha = 1
            quoteLabel.alpha = 0
            quoteLabel.text = nil
            pressCount = 0
            if let yes = screenshotTimer?.valid {
                if yes {
                    screenshotTimer?.invalidate()
                }
            }
        }
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
    
    // MARK: Called when quote is dismissed
    func animateFadeQuote() {
        pressCount = 0
        quoteSummoned = false
        longPressToPauseAnimation.enabled = false
        chainedAnimationsWith(duration: 0.3,
            completion: { _ in
                self.quoteLabel.text = nil
                self.quoteLabel.font = UIFont(name: self.fontName, size: self.fontSize)
                self.longPressToPauseAnimation.enabled = true
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
        pressCount = 0
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            // Put expensive code here
            let authorName = self.currentAuthorQuotePair.author.hashtagName()
            let msg = "M▲GK from \(authorName)"
            
            dispatch_async(dispatch_get_main_queue()) {
                // FIXME: Crash happened here! 😲
                // Keep testing!!
                let activityVC = UIActivityViewController(activityItems: [msg,screenshot], applicationActivities: nil)
                activityVC.completionWithItemsHandler = {
                    (s: String!, ok: Bool, items: [AnyObject]!, err: NSError!) -> Void in
                    // Where you do something when the activity view is completed.
                    self.takingScreenShot = false
                    self.animateFadeQuote()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                var popUp: UIPopoverController!
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                    popUp = UIPopoverController(contentViewController: activityVC)
                }
                
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                    popUp.presentPopoverFromRect(CGRectMake(self.heartLabel.frame.origin.x + 13, self.heartLabel.frame.origin.y, 2, 2), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: false)
                } else {
                    self.presentViewController(activityVC, animated: true, completion: nil)
                }
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
                                self.finishedIntro = true
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
        longPressToPauseAnimation = UILongPressGestureRecognizer(
            target: self,
            action: MagickSelectors.LongPress
        )
        longPressToPauseAnimation.minimumPressDuration = 0.124
        self.view.addGestureRecognizer(longPressToPauseAnimation)
    }
    
    private func updateScreenShotTimer() {
        
        screenshotTimer = NSTimer.scheduledTimerWithTimeInterval(timeRemainingToTakeScreenshot,
            target: self,
            selector: MagickSelectors.AnimateFadeQuote,
            userInfo: nil,
            repeats: false
        )
    }
}

