//
//  ViewController.swift
//  MagkQuotes
//
//  Created by Joshua Tate on 2015-07-19.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

// TODO: Refactor - it's a mess
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
        
        addMotionEffectToImageAndQuote()
        
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
                longPressToPauseAnimation.enabled = false
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

                        self.displayQuote()
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
            completion: { flag in
                if flag {
                    dispatch_async(dispatch_get_main_queue()) {
                        let screenshot = self.generateScreenShot(before: nil, after: nil)
                        self.presentAcitvityViewControllerWithScreenShot(screenshot)
                    }
                }
            },
            animations: [
                {
                    self.heartLabel.alpha = 0.0
                    self.heartLabel.transform = CGAffineTransformMakeScale(1.6, 1.6)
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
    private func generateScreenShot(before before: (() -> Void)?, after: (() -> Void)?) -> UIImage {
        
        if let before = before { before() }
        
        if UIScreen.mainScreen().respondsToSelector(Selector("scale")) {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.mainScreen().scale)
        } else {
            UIGraphicsBeginImageContext(self.view.bounds.size)
        }
        
        self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
        
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let after = after { after() }
        
        return screenshot
    }
    
    private func setRandomColor() {
        view.backgroundColor = UIColor.getRandomColor()
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
        quoteSummoned = false
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            // Put expensive code here
            let authorName = self.currentAuthorQuotePair.author.hashtagName()
            let msg = "M▲GK from \(authorName)"
            let rectToPopFrom = CGRectMake(5,20,0,0)
            
            dispatch_async(dispatch_get_main_queue()) {
                // FIXME: Crash happened here! 😲
                // Keep testing!!
                let activityVC = UIActivityViewController(activityItems: [msg,screenshot], applicationActivities: nil)
                activityVC.completionWithItemsHandler = {
                    _ -> Void in
                    // Where you do something when the activity view is completed.
                    self.animateFadeQuote()
                    self.takingScreenShot = false
//                    self.updateScreenShotTimer()
                    //self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                    let popUp = UIPopoverController(contentViewController: activityVC)
                    popUp.presentPopoverFromRect(rectToPopFrom,
                        inView: self.view,
                        permittedArrowDirections: UIPopoverArrowDirection.Up,
                        animated: true
                    )
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
    
    private func addMotionEffectToImageAndQuote() {
        let strength1: CGFloat = 1.0
        let strength2: CGFloat = 0.8
        
        imageView.addParallaxAndShadowEffects(strength1, addShadow: true)
        countdownLabel.addParallaxAndShadowEffects(strength1, addShadow: false)
        quoteLabel.addParallaxAndShadowEffects(strength2, addShadow: false)
    }
    
    private func displayQuote() {
        chainedAnimationsWith(
            duration: 0.22,
            completion: { flag in
                
                self.imageView.transform = CGAffineTransformMakeScale(1, 1)
                
                chainedAnimationsWith(duration: 0.2,
                    completion: { flag in
                        self.longPressToPauseAnimation.enabled = true
                    },
                    animations: [
                        {
                            //self.setRandomColor()
                            self.quoteLabel.alpha = 1.0
                            
                            self.quoteLabel.transform = CGAffineTransformMakeScale(1.07, 1.07)
                        },
                        {
                            self.quoteLabel.transform = CGAffineTransformMakeScale(0.98, 0.98)
                        },
                        {
                            self.quoteLabel.transform = CGAffineTransformMakeScale(1, 1)
                        }
                    ])
                
            },
            animations: [
                {
                    self.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7)
                },
                {
                    self.imageView.transform = CGAffineTransformMakeScale(1.7, 1.7)
                    self.imageView.alpha = 0.0
                    self.setRandomColor()
                }
            ]
        )
    }
}

