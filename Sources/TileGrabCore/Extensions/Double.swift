//
//  Double.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-12-07.
//

import Foundation

extension Double {
    init(string: String) throws {
        guard let double = Double(string) else {
            throw ConversionError.conversion("Expected `Double`, got `\(string)`")
        }
        self = double
    }
}
