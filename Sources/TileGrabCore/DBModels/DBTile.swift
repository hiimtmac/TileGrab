//
//  DBTile.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import GRDB

final class Tile {
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
    
    enum Columns: String, ColumnExpression {
        case x
        case y
        case z
        case data
    }
    
    var slug: String {
        return "x=\(x)&y=\(y)&z=\(z)"
    }
    
    var url: URL {
        return URL(string: "https://mt.google.com/vt/lyrs=s&\(slug)")!
    }
    
    var display: String {
        return "x=\(x) y=\(y) z=\(z)"
    }
    
    func children(max: Int) -> [Tile] {
        if z + 1 > max {
            return []
        }
        
        let x1y1 = Tile(x: x * 2, y: y * 2, z: z + 1)
        let x1y2 = Tile(x: x * 2, y: y * 2 + 1, z: z + 1)
        let x2y1 = Tile(x: x * 2 + 1, y: y * 2, z: z + 1)
        let x2y2 = Tile(x: x * 2 + 1, y: y * 2 + 1, z: z + 1)
        
        let children = [x1y1, x1y2, x2y1, x2y2]
        return children.reduce(children, { $0 + $1.children(max: max) })
    }
}

extension Tile: Equatable {
    static func ==(lhs: Tile, rhs: Tile) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

extension Tile: Hashable {
    var hashValue: Int {
        return slug.hashValue
    }
}

extension Tile: FetchableRecord {
    convenience init(row: Row) {
        let x: Int = row[Columns.x]
        let y: Int = row[Columns.y]
        let z: Int = row[Columns.z]
        let data: Data? = row[Columns.data]
        self.init(x: x, y: y, z: z, data: data)
    }
}

extension Tile: TableRecord {
    static let databaseTableName = "tiles"
}

extension Tile: PersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.x] = x
        container[Columns.y] = y
        container[Columns.z] = z
        container[Columns.data] = data
    }
}


