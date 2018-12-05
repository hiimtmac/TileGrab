//
//  Placemark.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

class KMLPlacemark: XMLIndexerDeserializable {
    let name: String
    let description: String?
    let styleUrl: String?
    
    init(name: String, description: String?, styleUrl: String?) {
        self.name = name
        self.description = description
        self.styleUrl = styleUrl
    }
}

final class KMLLineStringPlacemark: KMLPlacemark {
    let lineString: KMLLineString
    
    init(name: String, description: String?, styleUrl: String?, lineString: KMLLineString) {
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
}

class KMLMultiGeometryLineStringPlacemark: KMLPlacemark {
    let multiGeometryLineString: KMLMultiGeometryLineString
    
    init(name: String, description: String?, styleUrl: String?, multiGeometryLineString: KMLMultiGeometryLineString) {
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
}

class KMLMultiGeometryPolygonPlacemark: KMLPlacemark {
    let multiGeometryPolygon: KMLMultiGeometryPolygon
    
    init(name: String, description: String?, styleUrl: String?, multiGeometryPolygon: KMLMultiGeometryPolygon) {
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
}

class KMLPolygonPlacemark: KMLPlacemark {
    let polygon: KMLPolygon
    
    init(name: String, description: String?, styleUrl: String?, polygon: KMLPolygon) {
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
}

class KMLPointPlacemark: KMLPlacemark {
    let point: KMLPoint
    
    init(name: String, description: String?, styleUrl: String?, point: KMLPoint) {
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
}
