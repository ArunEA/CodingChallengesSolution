//
//  FileParser.swift
//  
//
//  Created by Eswaramurthi, Arun on 26/08/24.
//

import Foundation

struct FileParser {
    private func getFileURL(_ filePath: String?) throws -> URL {
        guard var filePath = filePath, !filePath.isEmpty else {
            throw RuntimeError("File name should not be empty")
        }
        
        if filePath.split(separator: "/").count == 1 {
            filePath = "/" + FileManager()
                .currentDirectoryPath
                .split(separator: "/")
                .dropLast(1)
                .joined(separator: "/") + "/" + filePath
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

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
