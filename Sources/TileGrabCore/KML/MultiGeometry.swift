//
//  MultiGeometry.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLMultiGeometryLineString: XMLIndexerDeserializable {
    let lineString: KMLLineString
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLMultiGeometryLineString {
        return try KMLMultiGeometryLineString.init(
            lineString: element["LineString"].value()
        )
    }
}

struct KMLMultiGeometryPolygon: XMLIndexerDeserializable {
    let polygon: KMLPolygon
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLMultiGeometryPolygon {
        return try KMLMultiGeometryPolygon.init(
            polygon: element["Polygon"].value()
        )
    }
}
