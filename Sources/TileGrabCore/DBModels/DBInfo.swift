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
    let initialTL: String
    let initialBR: String
    let minZ: Int
    let maxZ: Int
    
    init(tl: CLLocationCoordinate2D, br: CLLocationCoordinate2D, min: Int, max: Int) {
        self.initialTL = "\(tl.latitude),\(tl.longitude)"
        self.initialBR = "\(br.latitude),\(br.longitude)"
        self.minZ = min
        self.maxZ = max
    }

    var tlCoord: CLLocationCoordinate2D {
        let components = initialTL.components(separatedBy: ",")
        let latitude = Double(components[0])!
        let longitude = Double(components[1])!
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var brCoord: CLLocationCoordinate2D {
        let components = initialBR.components(separatedBy: ",")
        let latitude = Double(components[0])!
        let longitude = Double(components[1])!
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension DBInfo: PersistableRecord {
    enum Columns: String, ColumnExpression {
        case initialTL
        case initialBR
        case minZ
        case maxZ
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.initialTL] = initialTL
        container[Columns.initialBR] = initialBR
        container[Columns.minZ] = minZ
        container[Columns.maxZ] = maxZ
    }
}

extension DBInfo: TableRecord {
    static let databaseTableName = "info"
}
