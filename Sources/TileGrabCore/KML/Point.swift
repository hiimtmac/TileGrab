//
//  Point.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash
import CoreLocation

struct KMLPoint: XMLIndexerDeserializable {
    let coordinates: CLLocationCoordinate2D
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLPoint {
        let coordinateString: String = try element["coordinates"].value()
        let coordinates = CLLocationCoordinate2D(coordinateString)
        
        return KMLPoint.init(
            coordinates: coordinates
        )
    }
}
