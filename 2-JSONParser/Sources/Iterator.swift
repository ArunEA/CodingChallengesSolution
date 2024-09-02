//
//  Iterator.swift
//
//
//  Created by Eswaramurthi, Arun on 26/08/24.
//

import Foundation

protocol IteratorProtocol {
    var position: Int { get }
    
    func hasNext() -> Bool
    mutating func peekNext() -> Character
    mutating func next() -> Character
}

struct Iterator: IteratorProtocol {
    private let content: String
    private lazy var size = content.count
    var position: Int = -1

    init(content: String) {
        self.content = content
    }
    
    func hasNext() -> Bool {
        return position < content.count - 1
    }
    
    mutating func skipWhitespace() {
        while hasNext() && (content[position + 1].isWhitespace || content[position + 1].isNewline) {
            position += 1
        }
    }

    mutating func peekNext() -> Character {
        skipWhitespace()
        return content[position + 1]
    }

    mutating func next() -> Character {
        skipWhitespace()
        position += 1
        return content[position]
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
}
