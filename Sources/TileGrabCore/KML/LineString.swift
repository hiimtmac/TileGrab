//
//  LineString.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash
import CoreLocation

struct KMLLineString: XMLIndexerDeserializable {
//    let tessellate: Int?
//    let coordinates: [CLLocationCoordinate2D]
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLLineString {
        let coordinatesString: String = try element["coordinates"].value()
        let coordinatesArray = coordinatesString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
        let coordinates = coordinatesArray.map { CLLocationCoordinate2D($0) }
        
        return try KMLLineString.init(
//            tessellate: element["tessellate"].value(),
//            coordinates: coordinates
        )
    }
}
