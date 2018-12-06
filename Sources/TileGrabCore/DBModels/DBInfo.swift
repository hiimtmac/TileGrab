//
//  DBInfo.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import GRDB
import CoreLocation

struct DBInfo {
    let tlLat: Double
    let tlLon: Double
    let brLat: Double
    let brLon: Double
    let minZ: Int
    let maxZ: Int
    
    init(tl: CLLocationCoordinate2D, br: CLLocationCoordinate2D, min: Int, max: Int) {
        self.tlLat = tl.latitude
        self.tlLon = tl.longitude
        self.brLat = br.latitude
        self.brLon = br.longitude
        self.minZ = min
        self.maxZ = max
    }
}

extension DBInfo: PersistableRecord {
    enum Columns: String, ColumnExpression {
        case tlLat
        case tlLon
        case brLat
        case brLon
        case minZ
        case maxZ
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.tlLat] = tlLat
        container[Columns.tlLon] = tlLon
        container[Columns.brLat] = brLat
        container[Columns.brLon] = brLon
        container[Columns.minZ] = minZ
        container[Columns.maxZ] = maxZ
    }
}

extension DBInfo: TableRecord {
    static let databaseTableName = "info"
}
