//
//  Int.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation

extension Int {
    init(string: String) throws {
        guard let int = Int(string) else {
            throw ConversionError.conversion("Expected `Int`, got `\(string)`")
        }
        self = int
    }
}
