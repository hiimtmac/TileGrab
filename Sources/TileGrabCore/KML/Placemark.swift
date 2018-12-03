//
//  Placemark.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import SWXMLHash
import CoreLocation

struct Placemark: XMLIndexerDeserializable {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let description: String
    
    static func deserialize(_ element: XMLIndexer) throws -> Placemark {
        let coordinateString = element["Point"]["coordinates"].element!.text
        return try Placemark(
            name: element["name"].value(),
            coordinate: CLLocationCoordinate2D(coordinateString),
            description: element["description"].value()
        )
    }
    
    var dbPoint: Point {
        return Point(title: name, subtitle: nil, latitude: coordinate.latitude, longitude: coordinate.longitude, clusterIdentifier: nil)
    }
}
