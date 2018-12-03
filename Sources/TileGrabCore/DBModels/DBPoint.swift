//
//  DBPoint.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import GRDB

final class Point {
    let title: String
    let subtitle: String?
    let latitude: Double
    let longitude: Double
    let clusterIdentifier: String?
    
    init(title: String, subtitle: String?, latitude: Double, longitude: Double, clusterIdentifier: String?) {
        self.title = title
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
        self.clusterIdentifier = clusterIdentifier
    }
}

extension Point: TableRecord {
    static let databaseTableName = "points"
}

extension Point: PersistableRecord {
    enum Columns: String, ColumnExpression {
        case title
        case subtitle
        case latitude
        case longitude
        case clusterIdentifier
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.title] = title
        container[Columns.subtitle] = subtitle
        container[Columns.latitude] = latitude
        container[Columns.longitude] = longitude
        container[Columns.clusterIdentifier] = clusterIdentifier
    }
}
