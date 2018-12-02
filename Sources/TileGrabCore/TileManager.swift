//
//  TileManager.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-11-30.
//

import Foundation
import GRDB
import Console

class TileManager {
    let tiles: Set<TileLocation>
    let queue: DatabaseQueue
    
    private var errors = [(TileLocation, Swift.Error)]()
    
    init(tiles: Set<TileLocation>, name: String) throws {
        self.tiles = tiles
        
        let config = Configuration()
        let base = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let path = base.appendingPathComponent("\(name).sqlite")
        let queue = try DatabaseQueue(path: path.absoluteString, configuration: config)
        
        self.queue = queue
    }
    
    func migrateDatabase() throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigrationWithDeferredForeignKeyCheck("v1") { db in
            try db.create(table: "tiles") { t in
                t.primaryKey((["x","y","z"]), onConflict: .replace)
                t.column("x", .text).notNull()
                t.column("y", .text).notNull()
                t.column("z", .text).notNull()
                t.column("data", .blob).notNull()
            }
        }
        
        try migrator.migrate(queue)
    }
    
    func vacuumDataase() throws {
        try queue.writeWithoutTransaction { db in
            try db.execute("VACUUM")
        }
    }
    
    func fetchMap(group: DispatchGroup, terminal: Terminal) {
        let tileCount = tiles.count
        terminal.output("Fetching \(tileCount) tiles...".consoleText())

        for (index, location) in tiles.enumerated() {
            
            group.enter()
            
            URLSession.shared.dataTask(with: location.url) { [weak self] (data, response, error) in
                defer {
                    group.leave()
                }
                
                if let error = error {
                    self?.errors.append((location, error))
                    terminal.output("Error".consoleText(color: .red) + " \(index + 1) of \(tileCount): \(location.display)".consoleText())
                    return
                }

                guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                    terminal.output("Error".consoleText(color: .red) + " \(index + 1) of \(tileCount): \(location.display)".consoleText())
                    self?.errors.append((location, Error.badResponse))
                    return
                }

                guard let data = data else {
                    terminal.output("Error".consoleText(color: .red) + " \(index + 1) of \(tileCount): \(location.display)".consoleText())
                    self?.errors.append((location, Error.missingData))
                    return
                }
                                
                do {
                    let data = TileData.init(data: data)
                    let tile = Tile.init(location: location, data: data)
                    try self?.persist(tile)
                    terminal.output("Success".consoleText(color: .green) + " \(index + 1) of \(tileCount): \(location.display)".consoleText())
                } catch {
                    terminal.output("Error".consoleText(color: .red) + " \(index + 1) of \(tileCount): \(location.display)".consoleText())
                    self?.errors.append((location, error))
                }
            }.resume()
        }
    }
    
    func persist(_ tile: Tile) throws {
        try queue.write { db in
            try tile.output.insert(db)
        }
    }
    
    enum Error: Swift.Error {
        case badResponse
        case missingData
        case failures
    }
}
