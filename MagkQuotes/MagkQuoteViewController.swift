//
//  ViewController.swift
//  MagkQuotes
//
//  Created by Joshua Tate on 2015-07-19.
//  Copyright (c) 2015 Josh Tate. All rights reserved.
//

import UIKit

class MagkQuoteViewController: UIViewController {

    // MARK:- Properties
    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Private Properties
    private let Grey1 = UIColor(red: 242, green: 242, blue: 242)
    
    // MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.animationImages = ImageResource.images
        imageView.animationDuration = 0.55
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = Grey1
        quoteLabel.hidden = true
        imageView.hidden = false
        
        imageView.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

