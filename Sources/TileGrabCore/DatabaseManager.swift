//
//  DatabaseManager.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import GRDB

class DatabaseManager {
    let queue: DatabaseQueue
    
    init(name: String, path: String) throws {
        let config = Configuration()
        let base = URL(fileURLWithPath: path, isDirectory: true)
        let path = base.appendingPathComponent("\(name).sqlite")
        
        self.queue =  try DatabaseQueue(path: path.absoluteString, configuration: config)
    }
    
    func migrateDatabase() throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigrationWithDeferredForeignKeyCheck("v1") { db in
            try db.create(table: "tiles") { t in
                t.primaryKey((["x","y","z"]), onConflict: .replace)
                t.column("x", .text).notNull()
                t.column("y", .text).notNull()
                t.column("z", .text).notNull()
                t.column("data", .blob)
            }
            
            try db.create(table: "info") { t in
                t.primaryKey((["initialTL","initialBR","minZ","maxZ"]), onConflict: .replace)
                t.column("initialTL", .text).notNull()
                t.column("initialBR", .text).notNull()
                t.column("minZ", .integer).notNull()
                t.column("maxZ", .integer).notNull()
            }
        }
        
        try migrator.migrate(queue)
    }
    
    func tileCount() throws -> Int {
        var count: Int?
        
        try queue.read { db in
            count = try Tile
                .fetchCount(db)
        }
        
        return count ?? 0
    }
    
    func tileWithoutData() throws -> [Tile] {
        var locations: [Tile] = []
        
        try queue.read { db in
            locations = try Tile
                .filter(Tile.Columns.data == nil)
                .fetchAll(db)
        }
        
        return locations
    }
    
    func insertLocations(_ tiles: [Tile]) throws {
        try queue.write { db in
            try tiles.forEach { try $0.insert(db) }
        }
    }
    
    func persist(tile: Tile) throws {
        try queue.write { db in
            try tile.save(db)
        }
    }
    
    func vacuumDataase() throws {
        try queue.writeWithoutTransaction { db in
            try db.execute("VACUUM")
        }
    }
}
