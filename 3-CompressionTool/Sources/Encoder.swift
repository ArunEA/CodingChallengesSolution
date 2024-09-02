//
//  Encoder.swift
//
//
//  Created by Eswaramurthi, Arun on 27/08/24.
//

import Foundation

class Encoder {
    private var prefixCodeTable = [Character: String]()
    
    func encode(_ content: String) throws -> Data {
        let frequencyTable = frequencyAnalysis(content)
        let nodes = frequencyTable.map { Node(weight: $0.value, character: $0.key) }
        let queue = PriorityQueue(values: nodes)
        
        while queue.count > 1 {
            let leftNode = queue.dequeue()
            let rightNode = queue.dequeue()
            let intermediateNode = IntermediateNode(
                weight: leftNode.weight + rightNode.weight,
                leftNode: leftNode,
                rightNode: rightNode
            )
            
            queue.enqueue(intermediateNode)
        }
        
        try createPrefixCodeTable(queue)
                
        let (compressedData, padding) = try compress(content)
        
        let metaData = (try headerText() + separator + String(padding) + separator)

        // Convert everything into data before writing to file
        var dataToWrite = metaData.data(using: .utf8)!
        dataToWrite.append(compressedData)
        
        return dataToWrite
    }
    
    // Analyse the frequency of the characters and create a table
    private func frequencyAnalysis(_ content: String) -> [Character: Int] {
        var freqTable = [Character: Int]()
        for char in content {
            if freqTable[char] == nil {
                freqTable[char] = 1
            } else {
                freqTable[char]! += 1
            }
        }
        
        return freqTable
    }
    
    private func createPrefixCodeTable(_ queue: PriorityQueue<Node>) throws {
        guard queue.count == 1 else {
            throw RuntimeError("All the items should fall under single parent node")
        }
        let node = queue.dequeue()
        try handleIntermediateNode(node, currentDepth: "")
    }
    
    private func handleIntermediateNode(_ node: Node, currentDepth: String) throws {
        guard let intermediateNode = node as? IntermediateNode else {
            throw RuntimeError("Only intermediate node should be passed")
        }
        
        if let leftNode = intermediateNode.leftNode as? IntermediateNode {
            try handleIntermediateNode(leftNode, currentDepth: currentDepth+"0")
        } else {
            guard let character = (intermediateNode.leftNode as? Node)?.character else {
                throw RuntimeError("Node should have a character")
            }
            
            prefixCodeTable[character] = currentDepth+"0"
        }
        
        if let rightNode = intermediateNode.rightNode as? IntermediateNode {
            try handleIntermediateNode(rightNode, currentDepth: currentDepth+"1")
        } else {
            guard let character = (intermediateNode.rightNode as? Node)?.character else {
                throw RuntimeError("Node should have a character")
            }
            
            prefixCodeTable[character] = currentDepth+"1"
        }
    }
    
    private func headerText() throws -> String {
        return try prefixCodeTable.reduce("") { (partialResult, keyValuePair) in
            // We are converting the header text into utf8 format
            // "A":0110 will become 65:0110
            // This is to ensure any pairs like ":":1010 will be parsed correctly
            // If we don't do this, output will look like ::1010 instead of 58:1010
            // Right now this parser doesn't provide support to multiutf8 values like emojis
            // Hence the first!
            guard let keyUtf8value = keyValuePair.key.utf8.first else {
                throw RuntimeError("We don't support multi utf8 values just yet!")
            }

            return partialResult + "\(keyUtf8value)\(keyValueSeparator)\(keyValuePair.value)\(keyPairSeparator)"
        }
    }
    
    private func compress(_ content: String) throws -> (Data, Int) {
        var compressedBinaryString = ""
        
        for character in content {
            guard let code = prefixCodeTable[character] else {
                throw RuntimeError("This shouldn't happen since all characters should have been encoded")
            }
            compressedBinaryString.append(contentsOf: code)
        }
        
        // Calculate padding
        let padding = (8 - (compressedBinaryString.count % 8)) % 8
        let paddedString = compressedBinaryString + String(repeating: "0", count: padding)
                        
        let compressedData = try binaryStringToData(paddedString)
        
        return (compressedData, padding)
    }
    
    func binaryStringToData(_ binaryString: String) throws -> Data {
        // Ensure the binary string is valid
        guard binaryString.count % 8 == 0 else {
            throw RuntimeError("The string should be divided into 8 equal parts")
        }
        
        var data = Data()
        let utf8View = binaryString.utf8
        let totalSize = binaryString.count
        
        for i in stride(from: 0, to: binaryString.count, by: 8) {
            let startIndex = utf8View.index(utf8View.startIndex, offsetBy: i)
            let endIndex = utf8View.index(startIndex, offsetBy: 8)
            let byteString = String(utf8View[startIndex..<endIndex])!
            
            if let byte = UInt8(byteString, radix: 2) {
                data.append(byte)
            } else {
                throw RuntimeError("Improper byte format")
            }
            
            reportProgress(Int(Double(i)*100/Double(totalSize)))
        }
        
        reportProgress(100)
        
        return data
    }
}
