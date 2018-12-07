//
//  StyleMap.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLStyleMap: XMLIndexerDeserializable {
    let id: String
    let pairs: [KMLPair]
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLStyleMap {
        let id: String = try element.value(ofAttribute: "id")
        return try KMLStyleMap.init(
            id: "#\(id)",
            pairs: element["Pair"].value()
        )
    }
}

extension KMLStyleMap: Equatable, Hashable {
    static func ==(lhs: KMLStyleMap, rhs: KMLStyleMap) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}

struct KMLPair: XMLIndexerDeserializable {
    let key: KMLPairKey
    let styleUrl: String
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLPair {
        let keyString: String = try element["key"].value()
        return try KMLPair.init(
            key: KMLPairKey(rawValue: keyString) ?? .normal,
            styleUrl: element["styleUrl"].value()
        )
    }
}

enum KMLPairKey: String {
    case normal
    case highlight
}
