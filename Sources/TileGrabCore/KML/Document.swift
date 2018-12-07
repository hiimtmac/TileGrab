//
//  Document.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLDocument: XMLIndexerDeserializable, JSONKMLConvertable {
    let name: String
    let styles: [KMLStyle]?
    let styleMaps: [KMLStyleMap]?
    let folders: [KMLFolder]?
    let placemarks: [KMLPlacemark]?
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLDocument {
        let points: [KMLPointPlacemark]? = try element["Placemark"]
            .filterAll({ e, _ in e.innerXML.contains("Point") })
            .value()
        
        let polygons: [KMLPolygonPlacemark]? = try element["Placemark"]
            .filterAll({ e, _ in e.innerXML.contains("Polygon") && !e.innerXML.contains("MultiGeometry") })
            .value()
        
        let multiPolygons: [KMLMultiGeometryPolygonPlacemark]? = try element["Placemark"]
            .filterAll({ e, _ in e.innerXML.contains("Polygon") && e.innerXML.contains("MultiGeometry") })
            .value()
        
        let lineStrings: [KMLLineStringPlacemark]?  = try element["Placemark"]
            .filterAll({ e, _ in e.innerXML.contains("LineString") && !e.innerXML.contains("MultiGeometry") })
            .value()
        
        let multiLineStrings: [KMLMultiGeometryLineStringPlacemark]?  = try element["Placemark"]
            .filterAll({ e, _ in e.innerXML.contains("LineString") && e.innerXML.contains("MultiGeometry") })
            .value()
        
        var placemarks: [KMLPlacemark] = []
        placemarks = placemarks + (points ?? [])
        placemarks = placemarks + (polygons ?? [])
        placemarks = placemarks + (multiPolygons ?? [])
        placemarks = placemarks + (lineStrings ?? [])
        placemarks = placemarks + (multiLineStrings ?? [])
        
        return try KMLDocument.init(
            name: element["name"].value(),
            styles: element["Style"].value(),
            styleMaps: element["StyleMap"].value(),
            folders: element["Folder"].value(),
            placemarks: placemarks
        )
    }
    
    func encode() -> JSONDocument {
        let points = placemarks?
            .compactMap { $0 as? KMLPointPlacemark }
            .map { $0.encode() } ?? []
        
        let polylines = placemarks?
            .compactMap { $0 as? KMLLineStringPlacemark }
            .map { $0.encode() } ?? []
        let multiPolylines = placemarks?
            .compactMap { $0 as? KMLMultiGeometryLineStringPlacemark }
            .map { $0.encode() } ?? []
        
        let polygons = placemarks?
            .compactMap { $0 as? KMLPolygonPlacemark }
            .map { $0.encode() } ?? []
        let multiPolygons = placemarks?
            .compactMap { $0 as? KMLMultiGeometryPolygonPlacemark }
            .map { $0.encode() } ?? []
        
        let f = folders?
            .map { $0.encode() } ?? []
        
        return JSONDocument.init(
            name: name,
            folders: f,
            points: points,
            polylines: polylines + multiPolylines,
            polygons: polygons + multiPolygons
        )
    }
    
    func styleMapMappings() -> [String: String] {
        guard let maps = styleMaps else { return [:] }
        
        var mappingKeys = [String: String]()
        for map in maps {
            if let normal = map.pairs.filter({ $0.key == .normal }).first {
                mappingKeys[map.id] = normal.styleUrl
            }
        }
        
        return mappingKeys
    }
}

struct JSONDocument: Encodable {
    let name: String
    let folders: [JSONFolder]
    let points: [JSONPointPlacemark]
    let polylines: [JSONPolylinePlacemark]
    let polygons: [JSONPolygonPlacemark]
}
