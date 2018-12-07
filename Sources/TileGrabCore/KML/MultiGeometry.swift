//
//  MultiGeometry.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLMultiGeometryLineString: XMLIndexerDeserializable {
    let lineStrings: [KMLLineString]?
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLMultiGeometryLineString {
        return try KMLMultiGeometryLineString.init(
            lineStrings: element["LineString"].value()
        )
    }
}

struct KMLMultiGeometryPolygon: XMLIndexerDeserializable {
    let polygons: [KMLPolygon]?
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLMultiGeometryPolygon {
        return try KMLMultiGeometryPolygon.init(
            polygons: element["Polygon"].value()
        )
    }
}
