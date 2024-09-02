//
//  Globals.swift
//
//
//  Created by Eswaramurthi, Arun on 02/09/24.
//

import Foundation

let separator = "|"
let keyPairSeparator = ","
let keyValueSeparator = ":"

func reportProgress(_ progressPercent: Int) {
    print("\rProgress: \(progressPercent)% [\(String(repeating: "=", count: progressPercent / 2))\(String(repeating: " ", count: 50 - progressPercent / 2))]", terminator: "")
}
