//
//  ConversionError.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-11.
//

import Foundation

enum ConversionError: Swift.Error {
    case conversion(String)
}

extension ConversionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .conversion(let msg): return "Conversion Error: \(msg)"
        }
    }
}
