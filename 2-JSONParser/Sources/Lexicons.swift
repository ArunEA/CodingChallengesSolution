//
//  File.swift
//  
//
//  Created by Eswaramurthi, Arun on 26/08/24.
//

import Foundation

enum Lexicons: Character {
    case objectStart = "{"
    case objectEnd = "}"
    case arrayStart = "["
    case arrayEnd = "]"
    case stringStartEnd = "\""
    case pairSeparator = ":"
    case comma = ","
    case trueStart = "t"
    case falseStart = "f"
    case nullStart = "n"
    
    case zeroStart = "0"
    case oneStart = "1"
    case twoStart = "2"
    case threeStart = "3"
    case fourStart = "4"
    case fiveStart = "5"
    case sixStart = "6"
    case sevenStart = "7"
    case eightStart = "8"
    case nineStart = "9"
}

enum Null: Character {
    case n = "n"
    case u = "u"
    case l = "l"
}

enum True: Character, CaseIterable {
    case t = "t"
    case r = "r"
    case u = "u"
    case e = "e"
}

enum False: Character, CaseIterable {
    case f = "f"
    case a = "a"
    case l = "l"
    case s = "s"
    case e = "e"
}

enum Numbers: Character, CaseIterable {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
}
