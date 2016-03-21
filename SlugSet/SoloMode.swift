//
//  SoloMode.swift
//  SlugSet
//
//  Created by Julio Franco on 3/13/16.
//  Copyright (c) 2016 Julio Franco. All rights reserved.
//

import UIKit

class SoloMode: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var setsAvailable: UILabel!
    @IBOutlet weak var cardsOnDeck: UILabel!
    
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
    var cardButtons: [UIButton]!
    
    var myDeck = Deck()
    var deck: [String] = []
    var cardCodesOnBoard: [String] = []
    
    var selectedCards = [String:UIButton]()
    

    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardButtons = [cardR0C0,cardR0C1,cardR0C2,cardR1C0,cardR1C1,cardR1C2,
                        cardR2C0,cardR2C1,cardR2C2,cardR3C0,cardR3C1,cardR3C2]
        
        for card in cardButtons {
            card.layer.cornerRadius = 10
            card.layer.borderWidth = 2
            card.layer.borderColor = StyleConstants.grayBorder.CGColor
        }
        
        myDeck.shuffleDeck()
        deck = myDeck.deck
        
        loadNext12CardsCodes()
        setButtonsCodesAndImages()
        updateCounters()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Button Actions
    
    @IBAction func goBackPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func aCardPressed(sender: UIButton) {

        // If card is currently selected, then deselect it
        // tag == 1 means card is currently selected
        if sender.tag == 1 {
            sender.layer.borderColor = StyleConstants.grayBorder.CGColor
            sender.tag = 0
            
            selectedCards.removeValueForKey(sender.currentTitle!)
            
        } else {
            sender.layer.borderColor = StyleConstants.blueBorder.CGColor
            sender.tag = 1
            
            selectedCards[sender.currentTitle!] = sender
            
        }
        
        
        if selectedCards.count == 3 {
            let codes: [String] = Array(selectedCards.keys)
            // Check if they are a set
            if checkSet(card1: codes[0], card2: codes[1], card3: codes[2]) {
                println("they are a set")
                
                for (k, v) in selectedCards {
                    v.tag = 0
                    v.layer.borderColor = StyleConstants.grayBorder.CGColor
                }
            }
            // They are not a set
            else {
                println("not a set")
                
                for (k, v) in selectedCards {
                    v.tag = 0
                    v.layer.borderColor = StyleConstants.grayBorder.CGColor
                    v.shake()
                }
                
            }
            
            
            selectedCards.removeAll()
            
            
            
        }
        
    }
    
    
    // MARK: Helper Methods
    
    // Removes the next 12 card codes from deck and adds them into cardCodesOnBoard
    func loadNext12CardsCodes() {
        for i in 1...12 {
            cardCodesOnBoard.append(deck.removeAtIndex(0))
        }
    }
    
    // Sets the card code to the Button as the button title text
    // and then sets the card image based on the card code just set
    func setButtonsCodesAndImages() {
        for (i,code) in enumerate(cardCodesOnBoard) {
            cardButtons[i].setTitle(code, forState: .Normal)
            var cardPath = CardPaths.path[code]!
            cardButtons[i].setBackgroundImage(UIImage(named: cardPath), forState: .Normal)
        }
    }
    
    // FIXME:
    // Updates the labels of setsAvailable and cardsOnDeck
    func updateCounters() {
        cardsOnDeck.text = String(deck.count)
    }
    
    
    
    // Check all 4 attributes of cards one by one and check
    // to see if they are all the same or all different
    func checkSet(#card1: String, card2: String, card3: String) -> Bool {
        if (card1 == "0" || card2 == "0" || card3 == "0") {
            return false
        }
        var set = true
        let abcd = "abcd" // String with 4 chars for counting index in for-loop
        for ( var i=0; (set && i<4); i++) {
            var index = advance(abcd.startIndex, i)
            set = checkAttributes(a: card1[index], b: card2[index], c: card3[index])
        }
        
        return set
    }
    
    // Check whether the passed attribute is the same or different for all 3 cards
    func checkAttributes(#a: Character, b: Character, c: Character) -> Bool {
        return ( (a == b && a == c) || ((a != b) && (a != c) && (b != c)) )
    }
    

    
}


// Shake function used when the 3 cards selected are not a set
// http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.4
        animation.values = [-15.0, 15.0, -5.0, 5.0, 0.0 ]
        layer.addAnimation(animation, forKey: "shake")
    }
}


