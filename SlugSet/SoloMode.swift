//
//  SoloMode.swift
//  SlugSet
//
//  Created by Julio Franco on 3/13/16.
//  Copyright (c) 2016 Julio Franco. All rights reserved.
//

import UIKit

class SoloMode: UIViewController {
    
    @IBOutlet weak var cardR0C0: UIButton!
    @IBOutlet weak var cardR0C1: UIButton!
    @IBOutlet weak var cardR0C2: UIButton!
    @IBOutlet weak var cardR1C0: UIButton!
    @IBOutlet weak var cardR1C1: UIButton!
    @IBOutlet weak var cardR1C2: UIButton!
    @IBOutlet weak var cardR2C0: UIButton!
    @IBOutlet weak var cardR2C1: UIButton!
    @IBOutlet weak var cardR2C2: UIButton!
    @IBOutlet weak var cardR3C0: UIButton!
    @IBOutlet weak var cardR3C1: UIButton!
    @IBOutlet weak var cardR3C2: UIButton!
    
    var cardsOnBoard: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsOnBoard = [cardR0C0,cardR0C1,cardR0C2,cardR1C0,cardR1C1,cardR1C2,
                        cardR2C0,cardR2C1,cardR2C2,cardR3C0,cardR3C1,cardR3C2]
        
        for card in cardsOnBoard {
            card.layer.cornerRadius = 10
            card.layer.borderWidth = 2
            card.layer.borderColor = StyleConstants.grayBorder.CGColor
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func aCardPressed(sender: UIButton) {

        // If card is currently selected, then deselect it
        // tag == 1 means card is currently selected
        if sender.tag == 1 {
            sender.layer.borderColor = StyleConstants.grayBorder.CGColor
            sender.tag = 0
        } else {
            sender.layer.borderColor = StyleConstants.blueBorder.CGColor
            sender.tag = 1
        }
    }
    
}


