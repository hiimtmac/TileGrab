//
//  Document.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLDocument: XMLIndexerDeserializable {
    let name: String
    let styles: [KMLStyle]
    let styleMaps: [KMLStyleMap]
    let folders: [KMLFolder]
    let placemarks: [KMLPlacemark]
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLDocument {
        return try KMLDocument.init(
            name: element["name"].value(),
            styles: element["Style"].value(),
            styleMaps: element["StyleMap"].value(),
            folders: element["Folder"].value(),
            placemarks: element["Placemark"].value()
        )
    }
}
