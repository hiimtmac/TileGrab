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
    var parsed: KMLDocument?
    var mappings: [String: String]?
    
    init(kmlPath: String, terminal: Terminal) throws {
        let url = URL(fileURLWithPath: kmlPath)
        let data = try Data(contentsOf: url)
        let xml = SWXMLHash.parse(data)
        self.document = xml["kml"]["Document"]
        self.terminal = terminal
    }
    
    mutating func intakeDocument() throws {
        let doc: KMLDocument = try document.value()
        
        let main = doc.styleMapMappings()
        let folderDocs = doc.folders?.reduce([KMLDocument](), { $0 + $1.subDocuments() }) ?? []
        let folderStyles = folderDocs.reduce(main, { dict, doc -> [String: String] in
            var copy = dict
            for pair in doc.styleMapMappings() {
                copy[pair.key] = pair.value
            }
            return copy
        })
        
        mappings = folderStyles
        parsed = doc
    }
    
    func encode(pretty: Bool) throws -> Data? {
        guard let doc = parsed else { return nil }
        
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = .prettyPrinted
        }
        
        let jsondoc = doc.encode()
        let data = try encoder.encode(jsondoc)
        
        if let map = mappings, var string = String(data: data, encoding: .utf8) {
            terminal.output("Replacing \(map.count) style mappings...".consoleText())
            
            for pair in map {
                string = string.replacingOccurrences(of: ">\(pair.key)<", with: ">\(pair.value)<")
            }
            
            return string.data(using: .utf8)!
        } else {
            return data
        }
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
