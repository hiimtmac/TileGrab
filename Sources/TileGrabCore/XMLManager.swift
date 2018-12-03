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
    let document: XMLIndexer
    
    init(kmlPath: String) throws {
        let url = URL(fileURLWithPath: kmlPath)
        let data = try Data(contentsOf: url)
        let xml = SWXMLHash.parse(data)
        self.document = xml["kml"]["Document"]
    }
    
    func getRegions(min: Int, max: Int) throws -> [TileRegion] {
        let placemarks = document["Folder"]["Placemark"].all
        
        var regions = [TileRegion]()
        for placemark in placemarks {
            let coordinatesString = placemark["Polygon"]["outerBoundaryIs"]["LinearRing"]["coordinates"].element!.text
            let components = coordinatesString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
            let coordinates = components.map { CLLocationCoordinate2D($0) }
            let lats = coordinates.map { $0.latitude }
            let lons = coordinates.map { $0.longitude }

            let tl = CLLocationCoordinate2D(latitude: lats.max()!, longitude: lons.min()!)
            let br = CLLocationCoordinate2D(latitude: lats.min()!, longitude: lons.max()!)
            let region = try TileRegion(tl: tl, br: br, min: min, max: max)
            regions.append(region)
        }
        
        return regions
    }
}
