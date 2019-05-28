//
//  DBTile.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import GRDB
import CoreLocation

final class DBTile {
    let x: Int
    let y: Int
    let z: Int
    var data: Data?
    
    init(x: Int, y: Int, z: Int, data: Data? = nil) {
        self.x = x
        self.y = y
        self.z = z
        self.data = data
    }
    
    var slug: String {
        return "\(x)/\(y)/\(z)"
    }
    
    func children(max: Int) -> [DBTile] {
        if z + 1 > max {
            return []
        }
        
        let x1y1 = DBTile(x: x * 2, y: y * 2, z: z + 1)
        let x1y2 = DBTile(x: x * 2, y: y * 2 + 1, z: z + 1)
        let x2y1 = DBTile(x: x * 2 + 1, y: y * 2, z: z + 1)
        let x2y2 = DBTile(x: x * 2 + 1, y: y * 2 + 1, z: z + 1)
        
        let children = [x1y1, x1y2, x2y1, x2y2]
        return children.reduce(children, { $0 + $1.children(max: max) })
    }
    
    var parentTile: DBTile {
        let pX = Int(floor(Double(x) / 2.0))
        let pY = Int(floor(Double(y) / 2.0))
        return DBTile(x: pX, y: pY, z: z - 1)
    }
    
    var childTiles: [DBTile] {
        let x1y1 = DBTile(x: x * 2, y: y * 2, z: z + 1)
        let x1y2 = DBTile(x: x * 2, y: y * 2 + 1, z: z + 1)
        let x2y1 = DBTile(x: x * 2 + 1, y: y * 2, z: z + 1)
        let x2y2 = DBTile(x: x * 2 + 1, y: y * 2 + 1, z: z + 1)
        
        return [x1y1, x1y2, x2y1, x2y2]
    }
    
    var topLeft: CLLocationCoordinate2D {
        return getCoordinate(x: x, y: y, zoom: z)
    }
    
    var bottomRight: CLLocationCoordinate2D {
        return getCoordinate(x: x + 1, y: y + 1, zoom: z)
    }
    
    /// straight distance to left side of tile
    func leftBuffer(for point: CLLocationCoordinate2D) -> CLLocationDistance {
        let me = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let l = CLLocation(latitude: point.latitude, longitude: topLeft.longitude)
        return me.distance(from: l)
    }
    
    /// straight distance to right side of tile
    func rightBuffer(for point: CLLocationCoordinate2D) -> CLLocationDistance {
        let me = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let r = CLLocation(latitude: point.latitude, longitude: bottomRight.longitude)
        return me.distance(from: r)
    }
    
    /// straight distance to top side of tile
    func topBuffer(for point: CLLocationCoordinate2D) -> CLLocationDistance {
        let me = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let t = CLLocation(latitude: topLeft.latitude, longitude: point.longitude)
        return me.distance(from: t)
    }
    
    /// straight distance to bottom side of tile
    func bottomBuffer(for point: CLLocationCoordinate2D) -> CLLocationDistance {
        let me = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let b = CLLocation(latitude: bottomRight.latitude, longitude: point.longitude)
        return me.distance(from: b)
    }
}

extension DBTile: Equatable {
    static func ==(lhs: DBTile, rhs: DBTile) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

extension DBTile: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(slug)
    }
}

// MARK: - Database
extension DBTile {
    enum Columns: String, ColumnExpression {
        case x
        case y
        case z
        case data
    }
}

extension DBTile: FetchableRecord {
    convenience init(row: Row) {
        let x: Int = row[Columns.x]
        let y: Int = row[Columns.y]
        let z: Int = row[Columns.z]
        let data: Data? = row[Columns.data]
        self.init(x: x, y: y, z: z, data: data)
    }
}

extension DBTile: TableRecord {
    static let databaseTableName = "tiles"
}

extension DBTile: PersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.x] = x
        container[Columns.y] = y
        container[Columns.z] = z
        container[Columns.data] = data
    }
}
