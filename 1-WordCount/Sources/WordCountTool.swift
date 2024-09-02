// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ArgumentParser

@main
struct WordCountTool: ParsableCommand {
    // Commandline options
    @Flag(name: .short) var count = false
    @Flag(name: .short) var lines = false
    @Flag(name: .short) var words = false
    @Flag(name: .short) var multibyteCharacters = false
    
    @Argument var filePath: String = ""
    @Argument var content: String = ""
        
    public func run() throws {
        var output = ""
        
        let (content, isFile) = try getFileContents(filePath)

        if count {
            output += "    \(try countBytes(content))"
        }
        
        if lines {
            output += "    \(try countLines(content))"
        }
        
        if words {
            output += "    \(try countWords(content))"
        }
        
        if multibyteCharacters {
            output += "    \(try countCharacters(content))"
        }
        
        if output.isEmpty {
            output += "    \(try countLines(content))"
            output += "    \(try countWords(content))"
            output += "    \(try countBytes(content))"
        }
        
        if isFile {
            output += "    \(filePath)"
        }
        
        print(output)
    }
    
    private func getFileURL(_ filePath: String?) throws -> URL {
        guard var filePath = filePath, !filePath.isEmpty else {
            throw RuntimeError("File name should not be empty")
        }
        
        if filePath.split(separator: "/").count == 1 {
            filePath = FileManager().currentDirectoryPath + "/" + filePath
        }
                
        if #available(macOS 13.0, *) {
            return URL.init(filePath: filePath)
        } else {
            return URL(fileURLWithPath: filePath)
        }
    }
    
    func getFileContents(_ filePath: String?) throws -> (content: String, isFile: Bool) {
        let fileUrl = try getFileURL(filePath)
        
        if FileManager().fileExists(atPath: fileUrl.relativePath) {
            if let fileContents = try? String(contentsOfFile: fileUrl.relativePath, encoding: .utf8) {
                return (content: fileContents, isFile: true)
            } else {
                throw RuntimeError("Error parsing the contents of the file")
            }
        } else {
            return (content: filePath ?? "", isFile: false)
        }
    }
}

// MARK: Word counting functions
extension WordCountTool {
    func countBytes(_ content: String) throws -> Int {
        return content.data(using: .utf8)?.count ?? 0
    }
    
    func countLines(_ content: String) throws -> Int {
        return content
            .split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
            .count
    }
    
    func countWords(_ content: String) throws -> Int {
        return content
            .split(omittingEmptySubsequences: true, whereSeparator: \.isWhitespace)
            .count
    }
    
    func countCharacters(_ content: String) throws -> Int {
        return content.count
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
