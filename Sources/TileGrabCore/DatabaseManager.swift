//
//  DatabaseManager.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import GRDB
import Console

class DatabaseManager {
    let queue: DatabaseQueue
    let terminal: Terminal
    
    init(path: String, deletingIfExists: Bool, terminal: Terminal) throws {
        if deletingIfExists && FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            try FileManager.default.removeItem(at: url)
        }
        
        let config = Configuration()
        self.queue =  try DatabaseQueue(path: path, configuration: config)
        self.terminal = terminal
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
            count = try DBTile
                .fetchCount(db)
        }
        
        return count ?? 0
    }
    
    func tilesWithoutData() throws -> [DBTile] {
        var locations: [DBTile] = []
        
        try queue.read { db in
            locations = try DBTile
                .filter(DBTile.Columns.data == nil)
                .fetchAll(db)
        }
        
        return locations
    }
    
    func insertLocations(_ tiles: [DBTile]) throws {
        terminal.output("Inserting \(tiles.count) locations into database...".consoleText())
        try queue.write { db in
            try tiles.forEach { try $0.insert(db) }
        }
    }
    
    func persist(tile: DBTile) throws {
        try queue.write { db in
            try tile.save(db)
        }
    }
    
    func persist(points: [Point]) throws {
        terminal.output("Saving \(points.count) points to database...".consoleText())
        try queue.write { db in
            try points.forEach { try $0.insert(db) }
        }
    }
    
    func vacuumDataase() throws {
        terminal.output("Vacuuming Database...")
        try queue.writeWithoutTransaction { db in
            try db.execute("VACUUM")
        }
        terminal.output("Vacuum Complete".consoleText(color: .green))
    }
}
