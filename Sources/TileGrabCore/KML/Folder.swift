//
//  Folder.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLFolder: XMLIndexerDeserializable {
    let name: String
    let desc: String?
    let documents: [KMLDocument]?
    let folders: [KMLFolder]?
    let placemarks: [KMLPlacemark]?
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLFolder {
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
        
        return try KMLFolder.init(
            name: element["name"].value(),
            desc: element["description"].value(),
            documents: element["Document"].value(),
            folders: element["Folder"].value(),
            placemarks: placemarks
        )
    }
}
