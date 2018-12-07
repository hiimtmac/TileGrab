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
            throw Error.conversion
        }
        self = double
    }
    
    enum Error: Swift.Error {
        case conversion
    }
}
