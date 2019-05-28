//
//  FillCommand.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import Console
import SPMUtility

struct FillCommand: Command {
    
    let command = "fill"
    let overview = "Continues downloading tiles that have no tile data"
    
    let terminal: Terminal
    let dbPathArg: OptionArgument<PathArgument>
    
    init(parser: ArgumentParser, terminal: Terminal) {
        let subparser = parser.add(subparser: command, overview: overview)
        dbPathArg = subparser.add(option: "--database", shortName: "-d", kind: PathArgument.self, usage: "Path to database file output", completion: .filename)
        self.terminal = terminal
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let dbPath: PathArgument
        if let dataFile = arguments.get(dbPathArg) {
            dbPath = dataFile
        } else {
            dbPath = try PathArgument(argument: terminal.ask("Path for database file? (sqlite)"))
        }
        
        let dataManager = try DatabaseManager(path: dbPath.path.pathString, deletingIfExists: false, terminal: terminal)
        try dataManager.migrateDatabase()

        let tilesToFetch = try dataManager.tilesWithoutData()
        if tilesToFetch.isEmpty {
            terminal.output("No tiles to fetch.")
            return
        }
        
        let sizeString = sizeForCount(tileCount: tilesToFetch.count)
        
        if !terminal.confirm("Download will grab \(sizeString) to \(dbPath.path.pathString). Continue?".consoleText()) {
            terminal.output("Oh well, maybe another time.")
            return
        }
        
        let downloadManager = DownloadManager(databaseManager: dataManager, terminal: terminal)
        
        let group = DispatchGroup()
        downloadManager.fetchMap(tiles: tilesToFetch, group: group, provider: GoogleProvider())
        group.wait()
        
        terminal.output("Download Complete".consoleText(color: .green))
        
        try dataManager.vacuumDatase()
    }
}
