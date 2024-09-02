//
//  Node.swift
//  
//
//  Created by Eswaramurthi, Arun on 29/08/24.
//

import Foundation

protocol Nodable {
    var weight: Int { get set }
}

class Node: Nodable, CustomStringConvertible {
    var weight: Int
    let character: Character?
    
    init(weight: Int, character: Character?) {
        self.weight = weight
        self.character = character
    }
    
    var description: String {
        return "\(character!): \(weight)"
    }
}

// Intermediate node that always contain a left and right nodes
class IntermediateNode: Node {
    var leftNode: Nodable
    var rightNode: Nodable
    
    init(weight: Int, leftNode: Nodable, rightNode: Nodable) {
        self.leftNode = leftNode
        self.rightNode = rightNode
        
        super.init(weight: leftNode.weight + rightNode.weight, character: nil)
    }
    
    override var description: String {
        return "WEIGHT: \(weight), \n\t leftNode: \(leftNode), \n\trightNode: \(rightNode)"
    }
}
