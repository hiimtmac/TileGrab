//
//  KMLManager.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import SWXMLHash
import CoreLocation

struct KMLManager {
    let document: XMLIndexer
    
    init(kmlPath: String) throws {
        let url = URL(fileURLWithPath: kmlPath)
        let data = try Data(contentsOf: url)
        let xml = SWXMLHash.parse(data)
        self.document = xml["kml"]["Document"]
    }
    
    func makeDocument() {
        do {
            let doc: KMLDocument = try document.value()
            print(doc)
        } catch {
            print(error)
        }
    }
    
    func getRegions() throws -> [TileRegion] {
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
            let region = TileRegion(tl: tl, br: br)
            regions.append(region)
        }
        
        return regions
    }
    
    func getPaths(buffer: Double) throws -> [TilePath] {
        let lineStrings: [KMLLineStringPlacemark] = try document["Folder"]["Placemark"].value()
        
        var paths = [TilePath]()
        for line in lineStrings {
            let path = TilePath(coordinates: line.lineString.coordinates, buffer: buffer)
            paths.append(path)
        }
        
        return paths
    }
}
