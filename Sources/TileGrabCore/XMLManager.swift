//
//  XMLManager.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import SWXMLHash
import CoreLocation

struct XMLManager {
    let data: Data
    
    func getRegions(min: Int, max: Int) throws -> [TileRegion] {
        let xml = SWXMLHash.parse(data)
        let placemarks = xml["kml"]["Document"]["Folder"]["Placemark"].all
        
        var regions = [TileRegion]()
        for placemark in placemarks {
            let coordinatesString = placemark["Polygon"]["outerBoundaryIs"]["LinearRing"]["coordinates"].element!.text
            let components = coordinatesString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
            let coordinates = components.map { Coordinate($0) }
            let lats = coordinates.map { $0.lat }
            let lons = coordinates.map { $0.lon }

            let tl = CLLocationCoordinate2D(latitude: lats.max()!, longitude: lons.min()!)
            let br = CLLocationCoordinate2D(latitude: lats.min()!, longitude: lons.max()!)
            let region = try TileRegion(tl: tl, br: br, min: min, max: max)
            regions.append(region)
        }
        
        return regions
    }
    
    struct Coordinate {
        let lat: Double
        let lon: Double
        let alt: Double
        
        init(_ string: String) {
            let components = string.components(separatedBy: ",")
            self.lat = Double(components[1])!
            self.lon = Double(components[0])!
            self.alt = Double(components[2])!
        }
    }
}
