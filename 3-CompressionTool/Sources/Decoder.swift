//
//  Decoder.swift
//
//
//  Created by Eswaramurthi, Arun on 29/08/24.
//

import Foundation

class Decoder {
    private var prefixCodeTable1 = [String: Character]()
    private var currentProgress = 0
    
    func decode(_ content: Data, writeTo outputFile: String) throws {
        let (compressedData, padding) = try extractMetaData(content)
        
        var byteStream = ""
        
        let fileHandler = FileHandler()
        let fh = try FileHandle(forWritingTo: fileHandler.getFileURL(outputFile))
        
        defer {
            fh.closeFile()
        }
        
        let totalSize = compressedData.count
        
        for (count, byte) in compressedData.enumerated() {
            var currentByte = String(byte, radix: 2)
            
            // Remove padding bits from the last byte
            if count == compressedData.count - 1 {
                currentByte = String(currentByte.dropLast(padding))
            }
            
            // Pad the binary string to ensure it is 8 bits long
            if currentByte.count < 8 {
                currentByte = String(repeating: "0", count: 8 - currentByte.count) + currentByte
            }
            
            for bit in currentByte {
                byteStream.append(bit)
                
                if let char = prefixCodeTable1[byteStream] {
                    if let data = String(char).data(using: .utf8) {
                        fh.write(data)
                    } else {
                        throw RuntimeError("Failed to encode character to data.")
                    }
                    byteStream = ""
                }
            }
            
            currentProgress = Int((Double(count) / Double(totalSize)) * 100)
            reportProgress(currentProgress)
        }
        
        reportProgress(100)
    }
    
    // TODO: Further optimise by extracting the header and forming the table in a single loop
    func extractMetaData(_ content: Data) throws -> (Data, Int) {
        guard let keyPairSeparator = keyPairSeparator.first,
              let keyValueSeparator = keyValueSeparator.first else {
            throw RuntimeError("Ideally this shouldn't happen since it is a constant value")
        }
        
        var currentIndex: Int = 0
        var headerText = ""
        for (index, byte) in content.enumerated() {
            let char = String(format: "%c", byte)
            
            if char == separator {
                currentIndex = index
                break
            }
            headerText += char
        }
        
        let pairs = headerText.split(separator: keyPairSeparator)
        
        // Each pair contains a key value formatted like this "77:01110011110" which
        // should get parsed into "01110011110:M", the key and value interchanges and
        // the utf8 value of the key is converted to the proper character
        try pairs.forEach { pair in
            let keyValue = pair.split(separator: keyValueSeparator)
            guard let utf8String = keyValue.first,
                  let utf8Value = UInt8(utf8String),
                  let char = String(format: "%c", utf8Value).first,
                  let key = keyValue.last
            else {
                throw RuntimeError("Malformed header")
            }
            
            prefixCodeTable1[String(key)] = char
        }
        
        // Move +1 for ignoring the separator
        currentIndex += 1
        
        var paddingText = ""
        for index in currentIndex..<content.count {
            let char = String(format: "%c", content[index])
            
            if char == separator {
                currentIndex = index
                break
            }
            paddingText += char
        }
        
        // Move +1 for ignoring the separator
        currentIndex += 1
        
        return (content[currentIndex...], Int(paddingText)!)
    }
}
