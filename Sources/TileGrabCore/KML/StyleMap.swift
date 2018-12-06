//
//  StyleMap.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLStyleMap: XMLIndexerDeserializable {
    let pairs: [KMLPair]
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLStyleMap {
        return try KMLStyleMap.init(
            pairs: element["Pair"].value()
        )
    }
}

struct KMLPair: XMLIndexerDeserializable {
    let key: String
    let styleUrl: String
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLPair {
        return try KMLPair.init(
            key: element["key"].value(),
            styleUrl: element["styleUrl"].value()
        )
    }
}

