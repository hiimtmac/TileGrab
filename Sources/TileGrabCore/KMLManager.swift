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
}
