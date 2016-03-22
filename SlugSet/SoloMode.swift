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
    
    var sets = [String]()
    var countOfSets = 0
    
    var hintsShownOnBoard = -1
    
    

    
    // MARK: - Overrides
    
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
        
        loadCardCodesOnBoard()
        loadButtonsCodesAndImages()
        
        findSetsOnBoard()
        updateCountersOnBoard()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Button Actions
    
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
    
    @IBAction func shuffleButtonPressed(sender: AnyObject) {
        shuffleDeck()
        
        // If after shuffling there are no sets on board, keep shuffling
        var mySets = findSetsOnBoard()
        while (mySets.count == 0) {
            shuffleDeck()
            mySets = findSetsOnBoard()
        }
        
        updateCountersOnBoard()
    }
    
    @IBAction func hintButtonPressed(sender: AnyObject) {
        //ONLY show the first 3 hints for the first set available
        
        // All 3 hints have been shown already, therefore clear them all
        if hintsShownOnBoard == 2 {
            // remove hinted cards
        }
        // Not all 3 hints have been shown, therefore show one
        else {
            hintsShownOnBoard++
            for button in cardButtons {
                if button.currentTitle! == sets[hintsShownOnBoard] {
                    button.layer.borderColor = StyleConstants.orangeBorder.CGColor
                    break
                }
            }
        }
        
    }
    
    @IBAction func newgameButtonPressed(sender: AnyObject) {
    }
    
    
    
    // MARK: - Helper Methods
    
    // Removes the next 12 card codes from deck and adds them into cardCodesOnBoard
    func loadCardCodesOnBoard() {
        for i in 1...12 {
            cardCodesOnBoard.append(deck.removeAtIndex(0))
        }
    }
    
    // Sets the card code to the Button as the button title text
    // and then sets the card image based on the card code just set
    func loadButtonsCodesAndImages() {
        for (i,code) in enumerate(cardCodesOnBoard) {
            cardButtons[i].setTitle(code, forState: .Normal)
            var cardPath = CardPaths.path[code]!
            cardButtons[i].setBackgroundImage(UIImage(named: cardPath), forState: .Normal)
        }
    }
    
    // Updates the labels of setsAvailable and cardsOnDeck
    func updateCountersOnBoard() {
        cardsOnDeck.text = String(deck.count)
        setsAvailable.text = String(countOfSets)
    }
    
    // FIXME:
    func shuffleDeck() {
        // Add the cards on board back to the deck and shuffle it
        for card in cardCodesOnBoard {
            deck.append(card)
        }
        deck.shuffle()
        
        // Clear board of card codes and load it again
        cardCodesOnBoard.removeAll()
        loadCardCodesOnBoard()
        
        
        //remove blue boder from selected cards
        //empty out selected cards
        //remove orange border from hint cards
        
        loadButtonsCodesAndImages()
        
        
    }
    
    
    
    
    // MARK: Set Logic
    
    // Finds and returns all sets on current board
    // Updates the counter of number of sets available
    func findSetsOnBoard() -> [String] {
        countOfSets = 0
        var set: Bool
        
        // Clear out the List of sets if needed
        if (!sets.isEmpty) { sets.removeAll() }
        
        // Iterating over List of 12 cards with 3 different cursors
        for (var spot1=0; spot1<cardCodesOnBoard.count-2; spot1++){ // First cursor starts at index 0
            for (var spot2=spot1+1; spot2<cardCodesOnBoard.count-1; spot2++){ // Second cursor starts at first+1
                for (var spot3=spot2+1; spot3<cardCodesOnBoard.count; spot3++){ // Third cursor starts at second+1
                    
                    // Checking all combinations of 3 cards
                    set = checkSet(card1: cardCodesOnBoard[spot1], card2: cardCodesOnBoard[spot2], card3: cardCodesOnBoard[spot3])
                    
                    //If set found add it to List of sets
                    if (set) {
                        println("it is a set: \(cardCodesOnBoard[spot1]) \(cardCodesOnBoard[spot2]) \(cardCodesOnBoard[spot3])")
                        sets.append(cardCodesOnBoard[spot1])
                        sets.append(cardCodesOnBoard[spot2])
                        sets.append(cardCodesOnBoard[spot3])
                        
                        countOfSets++;
                    }
                }
            }
        }
        println()
        return sets
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


