//
//  Deck.swift
//  SlugSet
//
//  Created by Julio Franco on 3/20/16.
//  Copyright (c) 2016 Julio Franco. All rights reserved.
//

import UIKit

class Deck {
    let cardCodes = ["1ROE", "2ROE", "3ROE", "1ROD", "2ROD", "3ROD",
                     "1ROF", "2ROF", "3ROF", "1RDE", "2RDE", "3RDE",
                     "1RDD", "2RDD", "3RDD", "1RDF", "2RDF", "3RDF",
                     "1RSE", "2RSE", "3RSE", "1RSD", "2RSD", "3RSD",
                     "1RSF", "2RSF", "3RSF", "1GOE", "2GOE", "3GOE",
                     "1GOD", "2GOD", "3GOD", "1GOF", "2GOF", "3GOF",
                     "1GDE", "2GDE", "3GDE", "1GDD", "2GDD", "3GDD",
                     "1GDF", "2GDF", "3GDF", "1GSE", "2GSE", "3GSE",
                     "1GSD", "2GSD", "3GSD", "1GSF", "2GSF", "3GSF",
                     "1YOE", "2YOE", "3YOE", "1YOD", "2YOD", "3YOD",
                     "1YOF", "2YOF", "3YOF", "1YDE", "2YDE", "3YDE",
                     "1YDD", "2YDD", "3YDD", "1YDF", "2YDF", "3YDF",
                     "1YSE", "2YSE", "3YSE", "1YSD", "2YSD", "3YSD",
                     "1YSF", "2YSF", "3YSF"]
    
    var deck: [String] = []
    
    func shuffleDeck () {
        deck = cardCodes
        deck.shuffle()
    }
}


// http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
// shuffle as a mutating array method
// This extension will let you shuffle a mutable Array instance in place:
extension Array {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}


