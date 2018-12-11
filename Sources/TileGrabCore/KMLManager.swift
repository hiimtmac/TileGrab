//
//  KMLManager.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import SWXMLHash
import Console
import CoreLocation

struct KMLManager {
    let terminal: Terminal
    let document: XMLIndexer
    
    init(kmlPath: String, terminal: Terminal) throws {
        let url = URL(fileURLWithPath: kmlPath)
        let data = try Data(contentsOf: url)
        let xml = SWXMLHash.parse(data)
        self.document = xml["kml"]["Document"]
        self.terminal = terminal
    }

    func encode(pretty: Bool) throws -> Data? {
        let doc: KMLDocument = try document.value()
        
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = .prettyPrinted
        }
        
        let jsondoc = doc.encode()
        return try encoder.encode(jsondoc)
    }
    
    func getRegions() throws -> [TileRegion]? {
        let kml: [KMLPolygonPlacemark]? = try document["Folder"]["Placemark"]
            .filterAll { e,_ in e.innerXML.contains("Polygon")}
            .value()
        
        guard let polygons = kml, !polygons.isEmpty else { return nil }
        
        var regions = [TileRegion]()
        for polygon in polygons {
            let coordinates = polygon.polygon.outerBoundaryIs.linearRing.coordinates
            let lats = coordinates.map { $0.latitude }
            let lons = coordinates.map { $0.longitude }
                        
            let tl = CLLocationCoordinate2D(latitude: lats.max()!, longitude: lons.min()!)
            let br = CLLocationCoordinate2D(latitude: lats.min()!, longitude: lons.max()!)
            let region = TileRegion(tl: tl, br: br)
            regions.append(region)
        }
        
        return regions
    }
    
    func getPaths(buffer: Double) throws -> [TilePath]? {
        let kml: [KMLLineStringPlacemark]? = try document["Folder"]["Placemark"]
            .filterAll { e,_ in e.innerXML.contains("LineString")}
            .value()
        
        guard let lineStrings = kml, !lineStrings.isEmpty else { return nil }
        
        var paths = [TilePath]()
        for line in lineStrings {
            let path = TilePath(coordinates: line.lineString.coordinates, buffer: buffer)
            paths.append(path)
        }
        
        return paths
    }
}
