// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ArgumentParser

@main
struct Executable: ParsableCommand {
    @Argument var originalFileName: String
    @Argument var compressedFileName: String
    @Argument var outputFileName: String
    
    @Flag(name: .short) var debug: Bool = false
    
    public func run() throws {
        DEBUG = debug
        
        let fileHandler = FileHandler()
        let (content, _) = try fileHandler.getFileContents(originalFileName)
        print("\nCompressing file")

        let encodedData = try Encoder().encode(content)
        
        print("\nCreating compressed file")
        
        try fileHandler.writeToFile(compressedFileName, content: encodedData)
        
        print("\nDecoding compressed file")
        
        let readContent = try fileHandler.readFileAsRawData(compressedFileName)
        try Decoder().decode(readContent, writeTo: outputFileName)
        
        debugPrint("\nComparing file sizes")
        
        try fileHandler.compareFileSizes(of: originalFileName, and: compressedFileName)
    }
}

var DEBUG: Bool = false
func debugPrint(_ content: String) {
    if DEBUG {
        print(content)
    }
}
