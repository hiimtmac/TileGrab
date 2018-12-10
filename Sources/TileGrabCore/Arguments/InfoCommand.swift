//
//  InfoCommand.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import Console
import Utility

struct InfoCommand: Command {
    
    let command = "info"
    let overview = "Gathers info for map"
    
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
        
        try dataManager.setInfo()
        terminal.output("Info Set".consoleText(color: .green))
        
        try dataManager.vacuumDatase()
    }
}
