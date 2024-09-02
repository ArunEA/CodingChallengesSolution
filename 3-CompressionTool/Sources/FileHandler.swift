//
//  FileParser.swift
//
//
//  Created by Eswaramurthi, Arun on 26/08/24.
//

import Foundation

struct FileHandler {
    func getFileURL(_ filePath: String?) throws -> URL {
        guard var filePath = filePath, !filePath.isEmpty else {
            throw RuntimeError("File name should not be empty")
        }
        
        if filePath.split(separator: "/").count == 1 {
            filePath = FileManager().currentDirectoryPath + "/" + filePath
        }
                
        let fileUrl: URL
        if #available(macOS 13.0, *) {
            fileUrl = URL.init(filePath: filePath)
        } else {
            fileUrl = URL(fileURLWithPath: filePath)
        }
        
        if FileManager().fileExists(atPath: fileUrl.relativePath) == false {
            try createFile(fileUrl)
        }
        
        return fileUrl
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
    
    func createFile(_ fileUrl: URL) throws {
        if FileManager().fileExists(atPath: fileUrl.relativePath) {
            try FileManager.default.removeItem(at: fileUrl)
        }
        
        if (FileManager.default.createFile(atPath: fileUrl.relativePath, contents: nil, attributes: nil)) {
            debugPrint("File created successfully \(fileUrl.lastPathComponent)")
        } else {
            throw RuntimeError("File was not created successfully")
        }
    }
    
    func writeToFile(_ filePath: String?, content: Data) throws {
        let fileUrl = try getFileURL(filePath)
        try createFile(fileUrl)
        
        guard let fileHandle = FileHandle(forWritingAtPath: fileUrl.relativePath) else {
            throw RuntimeError("Could not open file handle to write file")
        }
        
        defer { fileHandle.closeFile() }
        
        let totalSize = content.count
        var bytesWritten = 0
        
        // Writing data by chunks since the io operations are costly
        while bytesWritten < totalSize {
            let remainingBytes = totalSize - bytesWritten
            let currentChunkSize = min(1024, remainingBytes)
            
            let chunk = content.subdata(in: bytesWritten..<bytesWritten + currentChunkSize)
            fileHandle.write(chunk)
            
            bytesWritten += currentChunkSize
            
            let progress = Double(bytesWritten) / Double(totalSize)
            
            reportProgress(Int(progress * 100))
        }
    }
    
    func readFileAsRawData(_ filePath: String) throws -> Data {
        let fileUrl = try getFileURL(filePath)
        let fileHandle: FileHandle?
        
        do {
            fileHandle = try FileHandle(forReadingFrom: fileUrl)
        } catch {
            throw RuntimeError("Error opening file: \(error)")
        }
        
        guard let handle = fileHandle else {
            throw RuntimeError("No file handle instance")
        }
        
        let fileData = handle.readDataToEndOfFile()
        handle.closeFile()
        
        return fileData
    }
    
    // MARK: File size comparisons
    private func fileSize(atPath path: String) throws -> UInt64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize = attributes[.size] as? UInt64 {
                return fileSize
            }
        } catch {
            throw RuntimeError("Error retrieving file size: \(error.localizedDescription)")
        }
        return nil
    }

    private func formatSize(_ size: UInt64) -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(size))
    }

    func compareFileSizes(of original: String, and compressed: String) throws {
        guard let fileSize1 = try fileSize(atPath: original) else {
            throw RuntimeError("Failed to get size for file at path: \(original)")
        }
        
        guard let fileSize2 = try fileSize(atPath: compressed) else {
            throw RuntimeError("Failed to get size for file at path: \(compressed)")
        }
        
        debugPrint("Original File Size: \(formatSize(fileSize1))")
        debugPrint("Compressed File Size: \(formatSize(fileSize2))")
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
