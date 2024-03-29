//
//  WikiViewController.swift
//  PlistReader
//
//  Created by Joshua Tate on 2015-08-27.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit
import WebKit

class WikiViewController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- Constants
    // MARK:-
    private struct Actions {
        static let RefreshButtonPressed = Selector("refreshButtonPressed:")
        static let EdgeSwiped = Selector("edgeSwiped:")
    }
    
    private struct KeyPaths {
        static let EstimatedProgress = "estimatedProgress"
    }
    
    // MARK:- Public Properties
    // MARK:-
    var wikiURL: NSURL?
    // MARK:- IBOutlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    // MARK:- Private Properties
    // MARK:- WebView Properties
    private let webView: WKWebView = WKWebView(frame: CGRectZero)
    private var loading = true
    private var refreshButtonIndex: Int!
    // MARK:- Instance Methods
    // MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Loading..."
        webView.navigationDelegate = self
        view.insertSubview(webView, atIndex: 0)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)

        let pinToBottomOfProgressView = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        let pinToTopOfToolBar = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: toolBar, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        view.addConstraints([pinToBottomOfProgressView, width, pinToTopOfToolBar])

        webView.addObserver(self, forKeyPath: KeyPaths.EstimatedProgress, options: NSKeyValueObservingOptions.New, context: nil)
        
        webView.allowsBackForwardNavigationGestures = true
        
        if let url = wikiURL {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        } else {
            displayError()
        }
        
        let barButtons = toolBar.items as [UIBarButtonItem]!
        for (index,button) in barButtons.enumerate() {
            if button === refreshButton {
                refreshButtonIndex = index
                break
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        backButton.enabled = false
        forwardButton.enabled = false
        actionButton.enabled = false
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == KeyPaths.EstimatedProgress {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: KeyPaths.EstimatedProgress)
        if loading { stoppedLoading() }
        clearWebsiteData()
    }
    
    // MARK:- IBActions
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        dismissWikiVC()
    }

    @IBAction func actionButtonPressed(sender: UIBarButtonItem) {
        let url = webView.URL!
        // TODO: Use launch activityVC(url: NSURL)
        //launchActivityVC(url)
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonPressed(sender: UIBarButtonItem) {
        webView.goForward()
    }

    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        if loading {
            webView.stopLoading()
        } else {
            let request = NSURLRequest(URL: webView.URL!)
            webView.loadRequest(request)
        }
    }
    
    // MARK:- WKNavigationDelegate Methods
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.hidden = false
        progressView.progressTintColor = UIColor.getProgressViewColor()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        title = "Loading..."
        actionButton.enabled = false
        loading = true
        updateRefreshButtonIdentifier()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        displayError()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        stoppedLoading()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        stoppedLoading()
    }
    
    // MARK:- Private functions
    private func displayError() {
        let alertVC = UIAlertController(title: "Error", message: "Error loading page.", preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "Exit", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
            self.dismissWikiVC()
        })
        alertVC.addAction(dismissAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    private func updateRefreshButtonIdentifier() {
        var newButton: UIBarButtonItem!
        if loading {
            newButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: Actions.RefreshButtonPressed)
        } else {
            newButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Actions.RefreshButtonPressed)
        }
        newButton.tintColor = UIColor.blackColor()
        toolBar.items?.removeAtIndex(refreshButtonIndex)
        toolBar.items?.insert(newButton, atIndex: refreshButtonIndex)
    }
    
    private func stoppedLoading() {
        loading = false
        progressView.setProgress(0, animated: true)
        if let webViewTitle = webView.title {
            title = webViewTitle.isWiki() ? webViewTitle.getWikiTitle() : webViewTitle
        }
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
        updateRefreshButtonIdentifier()
        actionButton.enabled = true
        //progressView.progressTintColor = UIColor.getProgressViewColor()
        progressView.hidden = true
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    private func launchActivityVC(url: NSURL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {
            _ -> Void in
            // Where you do something when the activity view is completed.
        }
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    private func dismissWikiVC() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func clearWebsiteData() {
        if #available(iOS 9.0, *) {
            let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            let dateFrom = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.defaultDataStore().removeDataOfTypes(websiteDataTypes, modifiedSince: dateFrom, completionHandler: {})
        } else {
            // Fallback on earlier versions
        }
    }
}

// MARK:- Private Extensions
private extension String {
    func isWiki() -> Bool {
        let words = self.componentsSeparatedByString(" ")
        return words.contains("Wikipedia,")
    }

    func getWikiTitle() -> String {
        let endIndex = self.rangeOfString(" -")!.startIndex
        return self.substringToIndex(endIndex)
    }
}

private extension UIColor {
    static func getProgressViewColor() -> UIColor {
        let colors: [(red: Int, green: Int, blue: Int)] = [
            (red: 242, green: 155, blue: 212),
            (red: 79, green: 111, blue: 140),
            (red: 122, green: 159, blue: 191),
            (red: 217, green: 35, blue: 83),
            (red: 168, green: 115, blue: 191),
            (red: 15, green: 166, blue: 138),
            (red: 166, green: 108, blue: 36),
            (red: 166, green: 36, blue: 60),
            (red: 242, green: 182, blue: 198),
            (red: 140, green: 74, blue: 50),
            (red: 140, green: 48, blue: 39),
            (red: 23, green: 26, blue: 38),
            (red: 145, green: 191, blue: 99),
            (red: 190, green: 217, blue: 150),
            (red: 205, green: 119, blue: 242),
            (red: 83, green: 45, blue: 166),
            (red: 59, green: 130, blue: 191),
            (red: 234, green: 242, blue: 5),
            (red: 242, green: 143, blue: 22),
            (red: 242, green: 94, blue: 122),
            (red: 242, green: 56, blue: 71),
            (red: 3, green: 44, blue: 166),
            (red: 242, green: 152, blue: 99),
            (red: 64, green: 1, blue: 1),
            (red: 242, green: 22, blue: 22),
            (red: 7, green: 140, blue: 40),
            (red: 242, green: 203, blue: 5),
            (red: 242, green: 183, blue: 5),
            (red: 242, green: 98, blue: 65),
            (red: 166, green: 33, blue: 3),
            (red: 166, green: 3, blue: 79),
            (red: 217, green: 4, blue: 121),
            (red: 242, green: 82, blue: 186),
            (red: 242, green: 140, blue: 215),
            (red: 5, green: 2, blue: 89),
            (red: 1, green: 4, blue: 64),
            (red: 38, green: 70, blue: 166),
            (red: 38, green: 81, blue: 166),
            (red: 38, green: 93, blue: 166),
            (red: 99, green: 135, blue: 166),
            (red: 166, green: 3, blue: 17),
            (red: 242, green: 46, blue: 62),
            (red: 242, green: 92, blue: 105),
            (red: 242, green: 153, blue: 121),
            (red: 239, green: 70, blue: 63)
        ]
        let codes = colors.randomElement()
        //println("code.red: \(codes.red) | codes.blue \(codes.blue) | codes.green \(codes.green)")
        return UIColor(red: codes.red, green: codes.green, blue: codes.blue)
    }
}