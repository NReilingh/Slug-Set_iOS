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
    
    
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    
    var newDeck = Deck()
    var deck: [String] = []
    var cardCodesOnBoard: [String] = []
    
    var selectedCards = [String:UIButton]()
    
    var sets = [String]()
    var countOfSets = 0
    
    var hintsShownOnBoard = -1
    
    
    
    var gameEnded = false
    

    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hintButton.alpha = 0
        shuffleButton.alpha = 0
        
        cardButtons = [cardR0C0,cardR0C1,cardR0C2,cardR1C0,cardR1C1,cardR1C2,
                        cardR2C0,cardR2C1,cardR2C2,cardR3C0,cardR3C1,cardR3C2]
        
        for card in cardButtons {
            card.layer.cornerRadius = 10
            card.layer.borderWidth = 2
            card.layer.borderColor = StyleConstants.grayBorder.CGColor
        }

        let defaults = NSUserDefaults.standardUserDefaults()
        let gameInProgress = defaults.boolForKey("gameInProgress")
        
        if gameInProgress {
            let data = defaults.objectForKey("savedDeck") as! NSData
            deck = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! [String]
        }else{
            newDeck.shuffleDeck()
            deck = newDeck.deck
        }
        
        loadCardCodesOnBoard()
        loadAllButtonsCodesAndImages()
        
        findSetsOnBoard()
        updateCountersOnBoard()
    }
    
    override func viewWillAppear(animated: Bool) {
        hintButton.fadeIn()
        shuffleButton.fadeIn()
    }
    
    override func viewWillDisappear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "gameInProgress")
        
        addCardsOnBoardBackToDeck()
        let data = NSJSONSerialization.dataWithJSONObject(deck, options: nil, error: nil)
        defaults.setObject(data, forKey: "savedDeck")
        defaults.synchronize()
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
        // Remove or add the blue border as needed
        if sender.tag == 1 {
            removeBlueBorderFrom(sender)
        } else {
            addBlueBorderTo(sender)
        }
        
        
        if selectedCards.count == 3 {
            removeOrangeBorderFromCards()
            
            let codes: [String] = Array(selectedCards.keys)
            // Check if the 3 selected cards are a set
            if checkSet(card1: codes[0], card2: codes[1], card3: codes[2]) {
                // Grab 3 more cards codes from the deck if the deck allows it
                if (deck.count >= 3) {
                    var newCodes = loadNextThreeCards()
                    updateButtonCodesAndImages(codes, newCodes: newCodes)
                    updateCardCodesOnBoard(codes, newCodes: newCodes)
                    
                    // Find the new sets, and shuffle if needed
                    var mySets = findSetsOnBoard()
                    while (mySets.count == 0) {
                        shuffleDeck()
                        mySets = findSetsOnBoard()
                    }
                    
                    updateCountersOnBoard()
                    
                }
                // There are no more cards on the deck
                else {
                    
                }
                
            }
            // They are not a set
            else {
                for (k, v) in selectedCards {
                    v.shake()
                }
            }
            removeBlueBorderFromCards()
        }
    }
    
    @IBAction func shuffleButtonPressed(sender: AnyObject) {
        removeBlueBorderFromCards()
        removeOrangeBorderFromCards()
        shuffleDeck()
        
        // If after shuffling there are no sets on board, keep shuffling
        var mySets = findSetsOnBoard()
        while (mySets.count == 0) {
            shuffleDeck()
            mySets = findSetsOnBoard()
        }
        
        updateCountersOnBoard()
    }
    
    //ONLY shows the first 3 hints of the first set found
    @IBAction func hintButtonPressed(sender: AnyObject) {
        removeBlueBorderFromCards()
        
        // Remove all hints
        if hintsShownOnBoard == 2 { // 0,1,2 three hints
            removeOrangeBorderFromCards()
        }
        // Show the next hint
        else {
            hintsShownOnBoard++
            addOrangeBorderToNextCard()
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
    func loadAllButtonsCodesAndImages() {
        for (i,code) in enumerate(cardCodesOnBoard) {
            cardButtons[i].setTitle(code, forState: .Normal)
            var cardPath = CardPaths.path[code]!
            cardButtons[i].setBackgroundImage(UIImage(named: cardPath), forState: .Normal)
        }
    }
    
    func loadNextThreeCards() -> [String] {
        var next3Cards: [String] = []
        for i in 1...3 {
            next3Cards.append(deck.removeAtIndex(0))
        }
        return next3Cards
    }
    
    func updateButtonCodesAndImages(oldCodes:[String], newCodes:[String]) {
        // Iterate through the old codes (the selected cards) and update the buttons with the new codes and images
        for (i,code) in enumerate(oldCodes) {
            var button: UIButton = selectedCards[code]!
            button.setTitle(newCodes[i], forState: .Normal)
            var cardPath = CardPaths.path[newCodes[i]]!
            
            button.zoomInAndOut({
                button.setBackgroundImage(UIImage(named: cardPath), forState: .Normal)
            })
        }
    }
    
    // Iterates through the old codes (selected cards) and traverses the array of buttons, once it finds the old code it replaces it with the new one
    func updateCardCodesOnBoard(oldCodes:[String], newCodes:[String]) {
        for (i, oldCode) in enumerate(oldCodes) {
            for (j, code) in enumerate(cardCodesOnBoard) {
                if code == oldCode {
                    cardCodesOnBoard[j] = newCodes[i]
                    break
                }
            }
        }
    }
    
    func updateCountersOnBoard() {
        cardsOnDeck.text = String(deck.count)
        setsAvailable.text = String(countOfSets)
    }
    
    func addCardsOnBoardBackToDeck() {
        // Need to reverse the order to add them in correct order on top of deck
        let board = cardCodesOnBoard.reverse()
        for card in board {
            deck.insert(card, atIndex: 0)
        }
    }
    
    func shuffleDeck() {
        // Add the cards on board back to the deck and shuffle it
        for card in cardCodesOnBoard {
            deck.append(card)
        }
        deck.shuffle()
        
        // Clear board of card codes and load it again
        cardCodesOnBoard.removeAll()
        loadCardCodesOnBoard()
        loadAllButtonsCodesAndImages()
    }
    
    
    // MARK: Color Border Logic
    
    func addBlueBorderTo(button: UIButton) {
        button.layer.borderColor = StyleConstants.blueBorder.CGColor
        button.tag = 1
        
        // Add the key-value ("code":Button) to the Dict
        selectedCards[button.currentTitle!] = button
    }
    
    func removeBlueBorderFrom(button: UIButton) {
        button.layer.borderColor = StyleConstants.grayBorder.CGColor
        button.tag = 0
        
        selectedCards.removeValueForKey(button.currentTitle!)
    }
    
    func removeBlueBorderFromCards() {
        // Get the codes from the selected cards dictionary
        let codes: [String] = Array(selectedCards.keys)
        // If its not empty, set the border of th button back to gray, and tag back to 0
        if !codes.isEmpty {
            for code in codes {
                selectedCards[code]!.tag = 0
                selectedCards[code]!.layer.borderColor = StyleConstants.grayBorder.CGColor
            }
        }
        selectedCards.removeAll()
    }
    
    func addOrangeBorderToNextCard() {
        for button in cardButtons {
            if button.currentTitle! == sets[hintsShownOnBoard] {
                button.layer.borderColor = StyleConstants.orangeBorder.CGColor
                button.tag = 0
                button.shake()
                break
            }
        }
    }
    
    func removeOrangeBorderFromCards() {
        if hintsShownOnBoard >= 0 {
            for (var i=0; i<=hintsShownOnBoard; i++) {
                for button in cardButtons {
                    if button.currentTitle! == sets[i] {
                        button.layer.borderColor = StyleConstants.grayBorder.CGColor
                        break
                    }
                }
            }
        }
        hintsShownOnBoard = -1
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
    
}// End of SoloMode class



extension UIView {
    
    // Shake animation used when the 3 cards selected are not a set
    // http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.4
        animation.values = [-15.0, 15.0, -5.0, 5.0, 0.0 ]
        layer.addAnimation(animation, forKey: "shake")
    }
    
    // Zoom in and out animation when a set is found and 3 cards get replaced
    // with completion block to show new images when zooming back in
    // http://stackoverflow.com/questions/31320819/scale-uibutton-animation-swift
    func zoomInAndOut(completionBlock: () -> Void) {
        UIView.animateWithDuration(0.25 ,
            animations: {
                self.transform = CGAffineTransformMakeScale(0.1, 0.1)
            },
            completion: { finish in
                UIView.animateWithDuration(0.25){
                    self.transform = CGAffineTransformIdentity
                }
                completionBlock()
        })
    }
    
    func fadeIn() {
        UIView.animateWithDuration(0.75, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.alpha = 1.0
            }, completion: nil)
    }
    func fadeOut() {
        UIView.animateWithDuration(0.75, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.alpha = 0.0
            }, completion: nil)
    }
}


