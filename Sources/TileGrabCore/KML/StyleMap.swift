//
//  StyleMap.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

typealias JSONStyleMap = KMLStyleMap
struct KMLStyleMap: XMLIndexerDeserializable, Encodable {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct KMLPair: XMLIndexerDeserializable, Encodable {
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

enum KMLPairKey: String, Encodable {
    case normal
    case highlight
}
