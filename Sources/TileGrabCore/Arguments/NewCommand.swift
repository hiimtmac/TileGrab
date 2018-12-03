//
//  NewCommand.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import Console
import Utility

struct NewCommand: Command {
    
    let command = "new"
    let overview = "Create new sqlite file from kml polygons & downloads"
    
    let terminal: Terminal
    let kmlPathArg: OptionArgument<PathArgument>
    let dbPathArg: OptionArgument<PathArgument>
    let minZArg: OptionArgument<Int>
    let maxZArg: OptionArgument<Int>
    let skippingZoomsArg: OptionArgument<Bool>
    
    init(parser: ArgumentParser, terminal: Terminal) {
        let subparser = parser.add(subparser: command, overview: overview)
        self.kmlPathArg = subparser.add(option: "--regions", shortName: "-r", kind: PathArgument.self, usage: "Path to kml file with regions", completion: .filename)
        self.dbPathArg = subparser.add(option: "--database", shortName: "-d", kind: PathArgument.self, usage: "Path to database file output", completion: .filename)
        self.minZArg = parser.add(option: "--max", kind: Int.self, usage: "Max Zoom")
        self.maxZArg = parser.add(option: "--min", kind: Int.self, usage: "Min Zoom")
        self.skippingZoomsArg = parser.add(option: "--skipping", shortName: "-s", kind: Bool.self, usage: "Skips every second zoom level")
        self.terminal = terminal
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let kmlPath: PathArgument
        if let regionsFile = arguments.get(kmlPathArg) {
            kmlPath = regionsFile
        } else {
            kmlPath = try PathArgument(argument: terminal.ask("Path for regions file? (kml)"))
        }
        
        let dbPath: PathArgument
        if let dataFile = arguments.get(dbPathArg) {
            dbPath = dataFile
        } else {
            dbPath = try PathArgument(argument: terminal.ask("Path for database file? (sqlite)"))
        }
        
        let minZ: Int
        if let min = arguments.get(minZArg) {
            minZ = min
        } else {
            minZ = try Int(string: terminal.ask("Min Zoom"))
        }
        
        let maxZ: Int
        if let max = arguments.get(maxZArg) {
            maxZ = max
        } else {
            maxZ = try Int(string: terminal.ask("Max Zoom"))
        }
        
        let skippingZoom = arguments.get(skippingZoomsArg) ?? false
        
        let xmlManager = try XMLManager(kmlPath: kmlPath.path.asString)
        let regions = try xmlManager.getRegions(min: minZ, max: maxZ)
        let tileManager = TileManager(regions: regions)
        
        var tiles = tileManager.getTileLocations()
        
        if skippingZoom {
            let zooms = Array(minZ...maxZ)
            let filteredZooms = zooms.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
            tiles = tiles.filter { filteredZooms.contains($0.z) }
        }
        
        let dataManager = try DatabaseManager(path: dbPath.path.asString, deletingIfExists: true, terminal: terminal)
        try dataManager.migrateDatabase()
        try dataManager.insertLocations(tiles)
        
        let summary: ConsoleText =
            "\(regions.count)".consoleText(color: .blue) +
                " region(s) covering ~" +
                "\(regions.reduce(0, { $0 + $1.squareKM }))".consoleText(color: .blue) +
                " square km - Min/Max Zoom: " +
                "\(minZ)".consoleText(color: .blue) +
                " / " +
                "\(maxZ)".consoleText(color: .blue) +
                "\(skippingZoom ? " skipping every second layer": "")".consoleText()
        
        terminal.output(summary)
        
        let tilesToFetch = try dataManager.tilesWithoutData()
        let sizeString = sizeForCount(tileCount: tilesToFetch.count)
        
        if !terminal.confirm("Download will grab \(sizeString) to \(dbPath.path.asString). Continue?".consoleText()) {
            terminal.output("Oh well, maybe another time.")
            let url = URL(fileURLWithPath: dbPath.path.asString)
            try? FileManager.default.removeItem(at: url)
            return
        }
        
        let downloadManager = DownloadManager(databaseManager: dataManager, terminal: terminal)
        
        let group = DispatchGroup()
        downloadManager.fetchMap(tiles: tilesToFetch, group: group)
        group.wait()
        
        terminal.output("Download Complete".consoleText(color: .green))
        
        try dataManager.vacuumDataase()
    }
}
