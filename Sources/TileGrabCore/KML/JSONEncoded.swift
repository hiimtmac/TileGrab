//
//  JSONEncoded.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-12-07.
//

import Foundation

protocol JSONKMLConvertable {
    associatedtype JSON: Encodable
    func encode() -> JSON
}
