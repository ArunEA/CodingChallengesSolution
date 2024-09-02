//
//  File.swift
//
//
//  Created by Eswaramurthi, Arun on 26/08/24.
//

import Foundation

enum JSONValue: CustomStringConvertible {
    case string(String)
    case number(Int)
    case bool(Bool)
    case array([JSONValue])
    case dictionary([String: JSONValue])
    case null
    
    var description: String {
        return description(withIndentLevel: 0)
    }
    
    private func description(withIndentLevel indentLevel: Int) -> String {
        let indent = String(repeating: "    ", count: indentLevel)
        let nestedIndent = String(repeating: "    ", count: indentLevel + 1)
        
        switch self {
        case .string(let value):
            return "\"\(value)\""
        case .number(let value):
            return "\(value)"
        case .bool(let value):
            return "\(value)"
        case .array(let values):
            let valueDescriptions = values.map {
                $0.description(withIndentLevel: indentLevel + 1)
            }
            return "[\n" + valueDescriptions.joined(separator: ",\n").indented(by: nestedIndent) + "\n\(indent)]"
        case .dictionary(let dict):
            let dictDescriptions = dict.map { "\"\($0.key)\": \($0.value.description(withIndentLevel: indentLevel + 1))" }
            return "{\n" + dictDescriptions.joined(separator: ",\n").indented(by: nestedIndent) + "\n\(indent)}"
        case .null:
            return "null"
        }
    }
}


private extension String {
    func indented(by indent: String) -> String {
        return self.split(separator: "\n").map { indent + $0 }.joined(separator: "\n")
    }
}
