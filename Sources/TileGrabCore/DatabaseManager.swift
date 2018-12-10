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
                t.primaryKey((["tlLat","tlLon","brLat","brLon","minZ","maxZ"]), onConflict: .replace)
                t.column("tlLat", .text).notNull()
                t.column("tlLon", .text).notNull()
                t.column("brLat", .text).notNull()
                t.column("brLon", .text).notNull()
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
    
    func setInfo() throws {
        try queue.write { db in
            let _ = try DBInfo.deleteAll(db)
            
            let maxZ = try Int.fetchOne(db, "SELECT max(z) FROM tiles")!
            let minZ = try Int.fetchOne(db, "SELECT min(z) FROM tiles")!
            let maxX = try Int.fetchOne(db, "SELECT max(x) FROM tiles")!
            let minX = try Int.fetchOne(db, "SELECT min(x) FROM tiles")!
            let maxY = try Int.fetchOne(db, "SELECT max(y) FROM tiles")!
            let minY = try Int.fetchOne(db, "SELECT min(y) FROM tiles")!
            
            let tl = getCoordinate(x: minX, y: minY, zoom: minZ)
            let br = getCoordinate(x: maxX, y: maxY, zoom: minZ)
            
            let info = DBInfo(tl: tl, br: br, min: minZ, max: maxZ)
            try info.insert(db)
        }
    }
    
    func cleanDatabase() throws {
        terminal.output("Cleaning Database...")
        try queue.writeWithoutTransaction { db in
            let count = try DBTile
                .filter(DBTile.Columns.data == nil)
                .deleteAll(db)
            terminal.output("Deleted \(count) tiles".consoleText())
        }
        terminal.output("Cleaning Complete".consoleText(color: .green))
    }
    
    func vacuumDatase() throws {
        terminal.output("Vacuuming Database...")
        try queue.writeWithoutTransaction { db in
            try db.execute("VACUUM")
        }
        terminal.output("Vacuum Complete".consoleText(color: .green))
    }
}
