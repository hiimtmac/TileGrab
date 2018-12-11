//
//  Folder.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLFolder: XMLIndexerDeserializable, JSONKMLConvertable {
    let name: String
    let description: String?
    let documents: [KMLDocument]?
    let folders: [KMLFolder]?
    let placemarks: [KMLPlacemark]?
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLFolder {
//        print("Folder: ",element["name"].element!.text)

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
        
//        print(placemarks)
        
        return try KMLFolder.init(
            name: element["name"].value(),
            description: element["description"].value(),
            documents: element["Document"].value(),
            folders: element["Folder"].value(),
            placemarks: placemarks
        )
    }
    
    func encode() -> JSONFolder {
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
        
        let d = documents?
            .map { $0.encode() } ?? []
        
        return JSONFolder.init(
            name: name,
            description: description,
            documents: d,
            folders: f,
            points: points,
            polylines: polylines,
            multiPolylines: multiPolylines,
            polygons: polygons,
            multiPolygons: multiPolygons
        )
    }
}

struct JSONFolder: Encodable {
    let name: String
    let description: String?
    let documents: [JSONDocument]
    let folders: [JSONFolder]
    let points: [JSONPointPlacemark]
    let polylines: [JSONPolylinePlacemark]
    let multiPolylines: [JSONMultiGeometryPolylinePlacemark]
    let polygons: [JSONPolygonPlacemark]
    let multiPolygons: [JSONMultiGeometryPolygonPlacemark]
}
