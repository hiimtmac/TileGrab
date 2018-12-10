//
//  CleanCommand.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-12-10.
//

import Foundation
import Console
import Utility

struct CleanCommand: Command {
    
    let command = "clean"
    let overview = "Deletes tiles that were not able to be downloaded"
    
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
        
        let dataManager = try DatabaseManager(path: dbPath.path.asString, deletingIfExists: false, terminal: terminal)
        try dataManager.migrateDatabase()
        
        let tilesToFetch = try dataManager.tilesWithoutData()
        if tilesToFetch.isEmpty {
            terminal.output("No tiles to delete.")
            return
        }
        
        if !terminal.confirm("Download will delete \(tilesToFetch.count). Continue?".consoleText()) {
            terminal.output("Oh well, maybe another time.")
            return
        }
        
        try dataManager.cleanDatabase()
        try dataManager.vacuumDatase()
    }
}
