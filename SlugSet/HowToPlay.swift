//
//  HowToPlay.swift
//  SlugSet
//
//  Created by Julio Franco on 3/24/16.
//  Copyright (c) 2016 Julio Franco. All rights reserved.
//

import UIKit

class HowToPlay: UIViewController {

    @IBOutlet weak var cardFeaturesContainer: UIView!
    @IBOutlet weak var cardFeaturesContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var feature1Top: NSLayoutConstraint!
    @IBOutlet weak var feature2Top: NSLayoutConstraint!
    @IBOutlet weak var feature3Top: NSLayoutConstraint!
    @IBOutlet weak var feature4Top: NSLayoutConstraint!
    var featureHeight: CGFloat!
    let featureHeightScale: CGFloat = 0.22
    let featuresConstraintScale: CGFloat = 0.33
    
    @IBOutlet weak var exampleSetsContainerHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardFeaturesContainerHeight.constant = view.bounds.size.height * 0.42
        featureHeight = view.bounds.size.height * featureHeightScale
        print(cardFeaturesContainer.bounds.size.height)
        print(featureHeight)
        
        feature1Top.constant = (featureHeight * featuresConstraintScale)
        feature2Top.constant = (featureHeight * featuresConstraintScale)
        feature3Top.constant = (featureHeight * featuresConstraintScale)
        feature4Top.constant = (featureHeight * featuresConstraintScale)
        
        exampleSetsContainerHeight.constant = view.bounds.size.height * 0.34
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // featureHeightScale was found by first printing cardFeatureContainer
        // to see the real runtime size, then dividing it by the view height
        // featureHeightScale <- cardFeatureHeight / viewHeight
        print(cardFeaturesContainer.bounds.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

}


