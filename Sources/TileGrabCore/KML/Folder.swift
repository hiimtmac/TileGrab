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
    let description: String?
    let folders: [KMLFolder]
    let placemarks: [KMLPlacemark]
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLFolder {
        return try KMLFolder.init(
            name: element["name"].value(),
            description: element["description"].value(),
            folders: element["Folder"].value(),
            placemarks: element["Placemark"].value()
        )
    }
}
