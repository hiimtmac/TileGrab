//
//  Placemark.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash
import CoreLocation

class KMLPlacemark {
    let name: String?
    let description: String?
    var styleUrl: String?
    
    init(name: String?, description: String?, styleUrl: String?) {
        self.name = name
        self.description = description
        self.styleUrl = styleUrl
    }
}

struct JSONPolylinePlacemark: Encodable {
    let name: String?
    let description: String?
    let styleUrl: String?
    let polyline: [CLLocationCoordinate2D]
}

final class KMLLineStringPlacemark: KMLPlacemark, XMLIndexerDeserializable, JSONKMLConvertable {
    let lineString: KMLLineString
    
    init(name: String?, description: String?, styleUrl: String?, lineString: KMLLineString) {
        self.lineString = lineString
        super.init(name: name, description: description, styleUrl: styleUrl)
    }
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLLineStringPlacemark {
        return try KMLLineStringPlacemark.init(
            name: element["name"].value(),
            description: element["description"].value(),
            styleUrl: element["styleUrl"].value(),
            lineString: element["LineString"].value()
        )
    }
    
    func encode() -> JSONPolylinePlacemark {
        return JSONPolylinePlacemark.init(
            name: name,
            description: description,
            styleUrl: styleUrl,
            polyline: lineString.coordinates
        )
    }
}

struct JSONMultiGeometryPolylinePlacemark: Encodable {
    let name: String?
    let description: String?
    let styleUrl: String?
    let polylines: [[CLLocationCoordinate2D]]
}

final class KMLMultiGeometryLineStringPlacemark: KMLPlacemark, XMLIndexerDeserializable, JSONKMLConvertable {
    let multiGeometryLineString: KMLMultiGeometryLineString
    
    init(name: String?, description: String?, styleUrl: String?, multiGeometryLineString: KMLMultiGeometryLineString) {
        self.multiGeometryLineString = multiGeometryLineString
        super.init(name: name, description: description, styleUrl: styleUrl)
    }
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLMultiGeometryLineStringPlacemark {
        return try KMLMultiGeometryLineStringPlacemark.init(
            name: element["name"].value(),
            description: element["description"].value(),
            styleUrl: element["styleUrl"].value(),
            multiGeometryLineString: element["MultiGeometry"].value()
        )
    }
    
    func encode() -> JSONMultiGeometryPolylinePlacemark {
        return JSONMultiGeometryPolylinePlacemark.init(
            name: name,
            description: description,
            styleUrl: styleUrl,
            polylines: multiGeometryLineString.lineStrings?.map { $0.coordinates } ?? []
        )
    }
}

struct JSONPolygonPlacemark: Encodable {
    let name: String?
    let description: String?
    let styleUrl: String?
    let polygon: [CLLocationCoordinate2D]
}

final class KMLPolygonPlacemark: KMLPlacemark, XMLIndexerDeserializable, JSONKMLConvertable {
    let polygon: KMLPolygon
    
    init(name: String?, description: String?, styleUrl: String?, polygon: KMLPolygon) {
        self.polygon = polygon
        super.init(name: name, description: description, styleUrl: styleUrl)
    }
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLPolygonPlacemark {
        return try KMLPolygonPlacemark.init(
            name: element["name"].value(),
            description: element["description"].value(),
            styleUrl: element["styleUrl"].value(),
            polygon: element["Polygon"].value()
        )
    }
    
    func encode() -> JSONPolygonPlacemark {
        return JSONPolygonPlacemark.init(
            name: name,
            description: description,
            styleUrl: styleUrl,
            polygon: polygon.outerBoundaryIs.linearRing.coordinates
        )
    }
}

struct JSONMultiGeometryPolygonPlacemark: Encodable {
    let name: String?
    let description: String?
    let styleUrl: String?
    let polygons: [[CLLocationCoordinate2D]]
}

final class KMLMultiGeometryPolygonPlacemark: KMLPlacemark, XMLIndexerDeserializable, JSONKMLConvertable {
    let multiGeometryPolygon: KMLMultiGeometryPolygon
    
    init(name: String?, description: String?, styleUrl: String?, multiGeometryPolygon: KMLMultiGeometryPolygon) {
        self.multiGeometryPolygon = multiGeometryPolygon
        super.init(name: name, description: description, styleUrl: styleUrl)
    }
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLMultiGeometryPolygonPlacemark {
        return try KMLMultiGeometryPolygonPlacemark.init(
            name: element["name"].value(),
            description: element["description"].value(),
            styleUrl: element["styleUrl"].value(),
            multiGeometryPolygon: element["MultiGeometry"].value()
        )
    }
    
    func encode() -> JSONMultiGeometryPolygonPlacemark {
        return JSONMultiGeometryPolygonPlacemark.init(
            name: name,
            description: description,
            styleUrl: styleUrl,
            polygons: multiGeometryPolygon.polygons?.map { $0.outerBoundaryIs.linearRing.coordinates } ?? []
        )
    }
}

struct JSONPointPlacemark: Encodable {
    let name: String?
    let description: String?
    let styleUrl: String?
    let point: CLLocationCoordinate2D
}

final class KMLPointPlacemark: KMLPlacemark, XMLIndexerDeserializable, JSONKMLConvertable {
    let point: KMLPoint

    init(name: String?, description: String?, styleUrl: String?, point: KMLPoint) {
        self.point = point
        super.init(name: name, description: description, styleUrl: styleUrl)
    }
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLPointPlacemark {
        return try KMLPointPlacemark.init(
            name: element["name"].value(),
            description: element["description"].value(),
            styleUrl: element["styleUrl"].value(),
            point: element["Point"].value()
        )
    }
    
    func encode() -> JSONPointPlacemark {
        return JSONPointPlacemark.init(
            name: name,
            description: description,
            styleUrl: styleUrl,
            point: point.coordinates
        )
    }
}
