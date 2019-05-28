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
                t.column("x", .integer).notNull()
                t.column("y", .integer).notNull()
                t.column("z", .integer).notNull()
                t.column("data", .blob)
            }
            
            try db.create(table: "info") { t in
                t.primaryKey((["tlLat","tlLon","brLat","brLon","minZ","maxZ"]), onConflict: .replace)
                t.column("tlLat", .double).notNull()
                t.column("tlLon", .double).notNull()
                t.column("brLat", .double).notNull()
                t.column("brLon", .double).notNull()
                t.column("minZ", .integer).notNull()
                t.column("maxZ", .integer).notNull()
            }
        }
        
        try migrator.migrate(queue)
    }
    
    func tileCount() throws -> Int {
        return try queue.read { db in
            return try DBTile
                .fetchCount(db)
        }
    }
    
    func tilesWithoutData() throws -> [DBTile] {
        return try queue.read { db in
            return try DBTile
                .filter(DBTile.Columns.data == nil)
                .fetchAll(db)
        }
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
            
            let maxZ = try Int.fetchOne(db, sql: "SELECT max(z) FROM tiles")!
            let minZ = try Int.fetchOne(db, sql: "SELECT min(z) FROM tiles")!
            let maxX = try Int.fetchOne(db, sql: "SELECT max(x) FROM tiles WHERE z=?", arguments: [minZ])!
            let minX = try Int.fetchOne(db, sql: "SELECT min(x) FROM tiles WHERE z=?", arguments: [minZ])!
            let maxY = try Int.fetchOne(db, sql: "SELECT max(y) FROM tiles WHERE z=?", arguments: [minZ])!
            let minY = try Int.fetchOne(db, sql: "SELECT min(y) FROM tiles WHERE z=?", arguments: [minZ])!
            
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
            try db.execute(sql: "VACUUM")
        }
        terminal.output("Vacuum Complete".consoleText(color: .green))
    }
}
