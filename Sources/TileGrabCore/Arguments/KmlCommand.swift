//
//  KmlCommand.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import Console
import Utility

struct KmlCommand: Command {
    
    let command = "kml"
    let overview = "Get kml attributes into database"
    
    let terminal: Terminal
    let kmlPathArg: OptionArgument<PathArgument>
    let dbPathArg: OptionArgument<PathArgument>
    
    init(parser: ArgumentParser, terminal: Terminal) {
        let subparser = parser.add(subparser: command, overview: overview)
        self.kmlPathArg = subparser.add(option: "--attributes", shortName: "-a", kind: PathArgument.self, usage: "Path to kml file with regions", completion: .filename)
        self.dbPathArg = subparser.add(option: "--database", shortName: "-d", kind: PathArgument.self, usage: "Path to database file output", completion: .filename)
        self.terminal = terminal
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let kmlPath: PathArgument
        if let regionsFile = arguments.get(kmlPathArg) {
            kmlPath = regionsFile
        } else {
            kmlPath = try PathArgument(argument: terminal.ask("Path for attributes file? (kml)"))
        }
        
        let dbPath: PathArgument
        if let dataFile = arguments.get(dbPathArg) {
            dbPath = dataFile
        } else {
            dbPath = try PathArgument(argument: terminal.ask("Path for database file? (sqlite)"))
        }
        
        let dataManager = try DatabaseManager(path: dbPath.path.asString, deletingIfExists: false, terminal: terminal)
        try dataManager.migrateDatabase()
        
        let kmlManager = try KMLManager(kmlPath: kmlPath.path.asString)
        let placemarks = try kmlManager.getPlacemarks()
        let points = placemarks.map { $0.dbPoint }
        
        try dataManager.persist(points: points)
        try dataManager.vacuumDataase()
    }
}

