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
    @IBOutlet weak var newgameButton: UIButton!
    
    
    var newDeck = Deck()
    var deck: [String] = []
    var cardCodesOnBoard: [String] = []
    
    var selectedCards = [String:UIButton]()
    
    var sets = [String]()
    var countOfSets = 0
    
    var hintsShownOnBoard = -1
    
    

    
    // MARK: - VC Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hintButton.alpha = 0
        shuffleButton.alpha = 0
        newgameButton.alpha = 0
        
        cardButtons = [cardR0C0,cardR0C1,cardR0C2,cardR1C0,cardR1C1,cardR1C2,
                        cardR2C0,cardR2C1,cardR2C2,cardR3C0,cardR3C1,cardR3C2]
        
        for card in cardButtons {
            card.layer.cornerRadius = 10
            card.layer.borderWidth = 2
            card.layer.borderColor = StyleConstants.grayBorder.cgColor
        }

        let defaults = UserDefaults.standard
        let gameInProgress = defaults.bool(forKey: "gameInProgress")
        
        if gameInProgress {
            let data = defaults.object(forKey: "savedDeck") as! Data
            do {
                deck = try JSONSerialization.jsonObject(with: data) as! [String]
                loadCardCodesOnBoard()
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }else{
            startNewGame()
        }

        loadAllButtonsCodesAndImages(fromNewGame: false)
        checkIfGameEnded()
        updateCountersOnBoard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hintButton.fadeIn()
        shuffleButton.fadeIn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "gameInProgress")
        
        addCardsOnBoardBackToDeck()
        do {
            let data = try JSONSerialization.data(withJSONObject: deck)
            defaults.set(data, forKey: "savedDeck")
            defaults.synchronize()
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Button Actions
    
    @IBAction func goBackPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func aCardPressed(_ sender: UIButton) {
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
                    let newCodes = loadNextThreeCards()
                    updateCardCodesOnBoard(codes, newCodes: newCodes)
                    
                    // Find sets, and shuffle if needed
                    findSetsOnBoard()
                    var shuffled = false
                    while (sets.count == 0 && deck.count >= 3) {
                        shuffleDeck()
                        findSetsOnBoard()
                        shuffled = true
                    }
                    if shuffled {
                        loadAllButtonsCodesAndImages(fromNewGame: shuffled)
                    } else {
                        updateButtonCodesAndImages(codes, newCodes: newCodes)
                    }
                } else { // There are no more cards on the deck
                    let newCodes = ["0", "0", "0"]
                    updateButtonCodesAndImages(codes, newCodes: newCodes)
                    updateCardCodesOnBoard(codes, newCodes: newCodes)
                }
            } else { // The 3 cards were NOT a set
                for (_, v) in selectedCards {
                    v.shake()
                }
            }
            removeBlueBorderFromCards()
            checkIfGameEnded()
            updateCountersOnBoard()
        }
    }
    
    @IBAction func shuffleButtonPressed(_ sender: AnyObject) {
        removeBlueBorderFromCards()
        removeOrangeBorderFromCards()
        shuffleDeck()
        
        // If after shuffling there are no sets on board, keep shuffling
        var mySets = findSetsOnBoard()
        while (mySets.count == 0) {
            shuffleDeck()
            mySets = findSetsOnBoard()
        }
        
        loadAllButtonsCodesAndImages(fromNewGame: false)
        updateCountersOnBoard()
    }
    
    //ONLY shows the first 3 hints of the first set found
    @IBAction func hintButtonPressed(_ sender: AnyObject) {
        removeBlueBorderFromCards()
        
        // Remove all hints
        if hintsShownOnBoard == 2 { // 0,1,2 three hints
            removeOrangeBorderFromCards()
        }
        // Show the next hint
        else {
            hintsShownOnBoard += 1
            addOrangeBorderToNextCard()
        }
    }
    
    @IBAction func newgameButtonPressed(_ sender: AnyObject) {
        newgameButton.isEnabled = false
        newgameButton.fadeOut({
            self.newgameButton.isHidden = true
        })
        
        hintButton.alpha = 0
        hintButton.isHidden = false
        hintButton.fadeIn()
        shuffleButton.alpha = 0
        shuffleButton.isHidden = false
        shuffleButton.fadeIn()
        
        startNewGame()
        
        loadAllButtonsCodesAndImages(fromNewGame: true)
        findSetsOnBoard()
        updateCountersOnBoard()
    }
    
    
    
    // MARK: - Helper Methods
    
    func startNewGame() {
        newDeck.shuffleDeck()
        deck = newDeck.deck
        
        if !cardCodesOnBoard.isEmpty { cardCodesOnBoard.removeAll() }
        loadCardCodesOnBoard()
        
        findSetsOnBoard()
        while (sets.count == 0) {
            shuffleDeck()
            findSetsOnBoard()
        }
    }
    
    // Removes the next 12 card codes from deck and adds them into cardCodesOnBoard
    func loadCardCodesOnBoard() {
        for _ in 1...12 {
            cardCodesOnBoard.append(deck.remove(at: 0))
        }
    }

    // Sets the card code to the Button as the button title text
    // and then sets the card image based on the card code just set
    func loadAllButtonsCodesAndImages(fromNewGame: Bool) {
        for (i,code) in cardCodesOnBoard.enumerated() {
            cardButtons[i].setTitle(code, for: UIControlState())
            
            if fromNewGame {
                let cardPath = CardPaths.path[code]!
                cardButtons[i].zoomInAndOut({
                    self.cardButtons[i].setBackgroundImage(UIImage(named: cardPath), for: UIControlState())
                    self.cardButtons[i].isHidden = false
                })
            }else{
                if code == "0" {
                    cardButtons[i].isHidden = true
                }else{
                    let cardPath = CardPaths.path[code]!
                    cardButtons[i].setBackgroundImage(UIImage(named: cardPath), for: UIControlState())
                }
            }
        }
    }
    
    // Returns the next 3 card codes from the top of deck
    func loadNextThreeCards() -> [String] {
        var next3Cards: [String] = []
        for _ in 1...3 {
            next3Cards.append(deck.remove(at: 0))
        }
        return next3Cards
    }
    
    func updateButtonCodesAndImages(_ oldCodes:[String], newCodes:[String]) {
        // Iterate through the old codes (the selected cards) and update the buttons with the new codes and images
        for (i,code) in oldCodes.enumerated() {
            let button: UIButton = selectedCards[code]!
            button.setTitle(newCodes[i], for: UIControlState())
            
            if newCodes[i] == "0" {
                button.zoomInAndOut({
                    button.isHidden = true
                })
            }else{
                let cardPath = CardPaths.path[newCodes[i]]!
                button.zoomInAndOut({
                    button.setBackgroundImage(UIImage(named: cardPath), for: UIControlState())
                })
            }
        }
    }
    
    // Iterates through the old codes (selected cards) and traverses the array of buttons, once it finds the old code it replaces it with the new one
    func updateCardCodesOnBoard(_ oldCodes:[String], newCodes:[String]) {
        for (i, oldCode) in oldCodes.enumerated() {
            for (j, code) in cardCodesOnBoard.enumerated() {
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
        let board = cardCodesOnBoard.reversed()
        for card in board {
            deck.insert(card, at: 0)
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
    }
    
    func checkIfGameEnded() {
        findSetsOnBoard()
        
        if (deck.count == 0 && sets.count == 0) {
            hintButton.isHidden = true
            shuffleButton.isHidden = true
            newgameButton.isHidden = false
            newgameButton.isEnabled = true
            newgameButton.fadeIn()
        }
    }
    
    
    // MARK: Color Border Logic
    
    func addBlueBorderTo(_ button: UIButton) {
        button.layer.borderColor = StyleConstants.blueBorder.cgColor
        button.tag = 1
        
        // Add the key-value ("code":Button) to the Dict
        selectedCards[button.currentTitle!] = button
    }
    
    func removeBlueBorderFrom(_ button: UIButton) {
        button.layer.borderColor = StyleConstants.grayBorder.cgColor
        button.tag = 0
        
        selectedCards.removeValue(forKey: button.currentTitle!)
    }
    
    func removeBlueBorderFromCards() {
        // Get the codes from the selected cards dictionary
        let codes: [String] = Array(selectedCards.keys)
        // If its not empty, set the border of th button back to gray, and tag back to 0
        if !codes.isEmpty {
            for code in codes {
                selectedCards[code]!.tag = 0
                selectedCards[code]!.layer.borderColor = StyleConstants.grayBorder.cgColor
            }
        }
        selectedCards.removeAll()
    }
    
    func addOrangeBorderToNextCard() {
        for button in cardButtons {
            if button.currentTitle! == sets[hintsShownOnBoard] {
                button.layer.borderColor = StyleConstants.orangeBorder.cgColor
                button.tag = 0
                button.shake()
                break
            }
        }
    }
    
    func removeOrangeBorderFromCards() {
        if hintsShownOnBoard >= 0 {
            for i in 0...hintsShownOnBoard {
                for button in cardButtons {
                    if button.currentTitle! == sets[i] {
                        button.layer.borderColor = StyleConstants.grayBorder.cgColor
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
    @discardableResult
    func findSetsOnBoard() -> [String] {
        countOfSets = 0
        var set: Bool
        
        // Clear out the List of sets if needed
        if (!sets.isEmpty) { sets.removeAll() }
        
        // Iterating over List of 12 cards with 3 different cursors
        for spot1 in 0 ..< cardCodesOnBoard.count-2 { // First cursor starts at index 0
            for spot2 in spot1+1 ..< cardCodesOnBoard.count-1 { // Second cursor starts at first+1
                for spot3 in spot2+1 ..< cardCodesOnBoard.count { // Third cursor starts at second+1
                    
                    // Checking all combinations of 3 cards
                    set = checkSet(card1: cardCodesOnBoard[spot1], card2: cardCodesOnBoard[spot2], card3: cardCodesOnBoard[spot3])
                    
                    //If set found add it to List of sets
                    if (set) {
                        print("it is a set: \(cardCodesOnBoard[spot1]) \(cardCodesOnBoard[spot2]) \(cardCodesOnBoard[spot3])")
                        sets.append(cardCodesOnBoard[spot1])
                        sets.append(cardCodesOnBoard[spot2])
                        sets.append(cardCodesOnBoard[spot3])
                        
                        countOfSets += 1;
                    }
                }
            }
        }
        print()
        return sets
    }
    
    // Check all 4 attributes of cards one by one and check
    // to see if they are all the same or all different
    func checkSet(card1: String, card2: String, card3: String) -> Bool {
        if (card1 == "0" || card2 == "0" || card3 == "0") {
            return false
        }
        var set = true
        let abcd = "abcd" // String with 4 chars for counting index in for-loop
        for i in 0...3 {
            if !set {
                let index = abcd.index(abcd.startIndex, offsetBy: i)
                set = checkAttributes(a: card1[index], b: card2[index], c: card3[index])
            }
        }
        
        return set
    }
    
    // Check whether the passed attribute is the same or different for all 3 cards
    func checkAttributes(a: Character, b: Character, c: Character) -> Bool {
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
        layer.add(animation, forKey: "shake")
    }
    
    // Zoom in and out animation when a set is found and 3 cards get replaced
    // with completion block to show new images when zooming back in
    // http://stackoverflow.com/questions/31320819/scale-uibutton-animation-swift
    func zoomInAndOut(_ completionBlock: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25 ,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            },
            completion: { finish in
                UIView.animate(withDuration: 0.25, animations: {
                    self.transform = CGAffineTransform.identity
                })
                completionBlock()
            })
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.75, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.alpha = 1.0
            }, completion: nil)
    }
    func fadeOut(_ completionBlock: @escaping ()->Void) {
        UIView.animate(withDuration: 0.75, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.alpha = 0.0
            }, completion: { finish in
                completionBlock()
            })
    }
}


