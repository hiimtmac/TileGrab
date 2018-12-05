//
//  Polygon.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLPolygon: XMLIndexerDeserializable {
    let tessellate: Int?
    let outerBoundaryIs: KMLOuterBoundaryIs
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLPolygon {
        return try KMLPolygon.init(
            tessellate: element["tessellate"].value(),
            outerBoundaryIs: element["outerBoundaryIs"].value()
        )
    }
}

struct KMLOuterBoundaryIs: XMLIndexerDeserializable {
    let linearRing: KMLLinearRing
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLOuterBoundaryIs {
        return try KMLOuterBoundaryIs.init(
            linearRing: element["LinearRing"].value()
        )
    }
}
