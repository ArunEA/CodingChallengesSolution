//
//  File.swift
//
//
//  Created by Eswaramurthi, Arun on 26/08/24.
//

import Foundation

class JSONParser {
    internal init(content: String) {
        self.content = content
    }
    
    private let content: String
    private lazy var iterator = Iterator(content: content)
    
    func parseObject() throws -> JSONValue {
        try validate(Lexicons.objectStart.rawValue)
        
        var dict = [String: JSONValue]()
        
        guard Lexicons(rawValue: iterator.peekNext()) != .objectEnd else {
            return JSONValue.dictionary(dict)
        }
        
        repeat {
            // So the comma gets consumed only when parsing from the second pair
            if !dict.isEmpty {
                try validate(Lexicons.comma.rawValue)
            }
            
            if let (key, value) = try parsePair() {
                dict[key] = value
            } else {
                throw ParseError.invalidFormat(position: iterator.position)
            }
        } while (Lexicons(rawValue: iterator.peekNext()) == .comma)
        
        try validate(Lexicons.objectEnd.rawValue)
        
        return JSONValue.dictionary(dict)
    }
    
    func parsePair() throws -> (String, JSONValue)? {
        let peek = Lexicons(rawValue: iterator.peekNext())
        if peek == .objectEnd {
            return nil
        }
        
        guard case let .string(key) = try parseString() else {
            debugPrint(".string(key) = try parseString(): Position \(iterator.position)")
            throw ParseError.invalidFormat(position: iterator.position)
        }
        
        try validate(Lexicons.pairSeparator.rawValue)
        
        let value = try parseValue()
        
        return (key, value)
    }
    
    func parseValue() throws -> JSONValue {
        let peek = Lexicons(rawValue: iterator.peekNext())

        let parseFunctions: [Lexicons: () throws -> JSONValue] = [
            .objectStart: parseObject,
            .arrayStart: parseArray,
            .stringStartEnd: parseString,
            .trueStart: parseTrue,
            .falseStart: parseFalse,
            .nullStart: parseNull,
            .zeroStart: parseNumber,
            .oneStart: parseNumber,
            .twoStart: parseNumber,
            .threeStart: parseNumber,
            .fourStart: parseNumber,
            .fiveStart: parseNumber,
            .sixStart: parseNumber,
            .sevenStart: parseNumber,
            .eightStart: parseNumber,
            .nineStart: parseNumber
        ]

        if let peek = peek, let parseFunction = parseFunctions[peek] {
            return try parseFunction()
        } else {
            debugPrint("default: Position \(iterator.position), but only got \(peek?.rawValue ?? "E")")
            throw ParseError.invalidFormat(position: iterator.position)
        }
    }
    
    func parseArray() throws -> JSONValue {
        try validate(Lexicons.arrayStart.rawValue)
        
        var array = [JSONValue]()
        
        guard Lexicons(rawValue: iterator.peekNext()) != .arrayEnd else {
            return JSONValue.array(array)
        }
        
        repeat {
            // This is added so the comma gets consumed when parsing a second value
            if !array.isEmpty {
                try validate(Lexicons.comma.rawValue)
            }
            
            array.append(try parseValue())
        } while (Lexicons(rawValue: iterator.peekNext()) == .comma)
        
        try validate(Lexicons.arrayEnd.rawValue)
        
        return JSONValue.array(array)
    }
    
    func parseString() throws -> JSONValue {
        try validate(Lexicons.stringStartEnd.rawValue)
        
        var stringValue = ""
        
        while Lexicons(rawValue: iterator.peekNext()) != Lexicons.stringStartEnd {
            let character = iterator.next()
            stringValue += String(character)
        }
        
        try validate(Lexicons.stringStartEnd.rawValue)
        
        return JSONValue.string(stringValue)
    }
    
    func parseNumber() throws -> JSONValue {
        var loopControl = true
        var number = ""
        while loopControl {
            let peek = iterator.peekNext()
            if Numbers.allCases.contains(where: {
                $0.rawValue == peek
            }) {
                number += String(iterator.next())
            } else {
                loopControl = false
            }
        }
        
        return JSONValue.number(Int(number)!)
    }
    
    func parseTrue() throws -> JSONValue {
        try True.allCases.forEach {
            try validate($0.rawValue)
        }
        
        return JSONValue.bool(true)
    }
    
    func parseFalse() throws -> JSONValue {
        try False.allCases.forEach {
            try validate($0.rawValue)
        }
        
        return JSONValue.bool(false)
    }
    
    func parseNull() throws -> JSONValue {
        try validate(Null.n.rawValue)
        try validate(Null.u.rawValue)
        try validate(Null.l.rawValue)
        try validate(Null.l.rawValue)
        
        return JSONValue.null
    }
    
    func validate(_ expected: Character) throws {
        guard iterator.hasNext() else {
            throw RuntimeError("No characters to parse")
        }
        
        let nextCharacter = iterator.next()
        if nextCharacter == expected {
            return
        }
        
        debugPrint("Expected \(expected) at position \(iterator.position), but only got \(nextCharacter)")
        throw ParseError.invalidFormat(position: iterator.position)
    }
}

enum ParseError: Error {
    case invalidFormat(position: Int)
}
