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
    }

    // MARK:- Properties
    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Private Properties
    private let Grey1 = UIColor(red: 242, green: 242, blue: 242)
    
    private var quoteCollection: QuoteCollection!
    private var authorQuotePairs: [(author: Author, quote: Quote)]!
    
    // MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.animationImages = ImageResource.images
        imageView.animationDuration = 0.55
        
        let longPressToPauseAnimation = UILongPressGestureRecognizer(
            target: self,
            action: MagickSelectors.LongPress
        )
        longPressToPauseAnimation.minimumPressDuration = 0.168
        view.addGestureRecognizer(longPressToPauseAnimation)
        
        quoteCollection = QuoteCollection(fileName: "QuotePropertyList")
        authorQuotePairs = quoteCollection.generateAuthorQuotePairList()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = Grey1
        quoteLabel.alpha = 0.0
        quoteLabel.text = nil
        imageView.alpha = 1.0
        
        imageView.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- Custom Methods
    // MARK:- Gesture Recognizers
    func longPress(press: UILongPressGestureRecognizer) {
        
        if press.state == UIGestureRecognizerState.Began {
            let authorAndQuote = self.authorQuotePairs.removeLast()
            let quoteText = self.quoteCollection.authorQuoteString(authorAndQuote)
            self.quoteLabel.text = quoteText
            
            chainedAnimationsWith(
                duration: 0.2,
                completion: nil,
                animations: [
                    {
                        self.setRandomColor()
                        self.imageView.alpha = 0.0
                        self.quoteLabel.alpha = 1.0
                        
                        self.quoteLabel.transform = CGAffineTransformMakeScale(1.03, 1.03)
                    },
                    {

                        self.quoteLabel.transform = CGAffineTransformMakeScale(0.97, 0.97)
                    },
                    {
                        self.quoteLabel.transform = CGAffineTransformMakeScale(1, 1)
                    }
                ]
            )

        } else if press.state == UIGestureRecognizerState.Ended {

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
    }
    
    // MARK: Private Methods
    private func pauseLayer(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    private func resumeLayer(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    private func setRandomColor() {
        view.backgroundColor = getRandomColor()
    }
}

