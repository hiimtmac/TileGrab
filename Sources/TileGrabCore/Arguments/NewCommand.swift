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
    let kmlFileArg: OptionArgument<PathArgument>
    
    init(parser: ArgumentParser, terminal: Terminal) {
        let subparser = parser.add(subparser: command, overview: overview)
        self.kmlFileArg = subparser.add(option: "--kml-file", shortName: "-k", kind: PathArgument.self, usage: "Path to kml file.", completion: .filename)
        self.terminal = terminal
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        guard let kmlPath = arguments.get(kmlFileArg) else {
            throw ArgumentParserError.expectedValue(option: "Bad path")
        }
        
        
        var tileSet = Set<DBTile>()
        let kmlManager = try KMLManager(kmlPath: kmlPath.path.asString, terminal: terminal)
        let tileManager = TileManager()
        
//        let regionBuffer = try Double(string: terminal.ask("Region buffer distance (m)?"))
        if let regions = try kmlManager.getRegions() {
            terminal.output("\(regions.count)".consoleText(color: .magenta) + " regions found.\n".consoleText())
            
            let rMin = try Int(string: terminal.ask("Min zoom for regions?"))
            let rMax = try Int(string: terminal.ask("Max zoom for regions?"))
            
            var regionTiles = tileManager.calculateTileLocations(for: regions, minZ: rMin, maxZ: rMax, buffer: 0)//regionBuffer)
            
            var skipping = false
            if terminal.confirm("Skip every second zoom level?") {
                skipping = true
                let zooms = Array(rMin...rMax)
                let filteredZooms = zooms.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
                regionTiles = regionTiles.filter { filteredZooms.contains($0.z) }
            }
            
            let regionTileSet = Set(regionTiles)
            tileSet = tileSet.union(regionTileSet)
            
            let summary: ConsoleText =
                "\(regions.count)".consoleText(color: .cyan) +
                " region(s) covering ~" +
                "\(regions.reduce(0, { $0 + $1.squareKM }))".consoleText(color: .cyan) +
                " square km - Min/Max Zoom: " +
                "\(rMin)".consoleText(color: .cyan) +
                " / " +
                "\(rMax)".consoleText(color: .cyan) +
                " - TILES: ".consoleText() +
                "\(regionTileSet.count)".consoleText(color: .cyan) +
                "\(skipping ? " (skipping every second layer)\n": "\n")".consoleText()
            
            terminal.output(summary)
        } else {
            terminal.output("No regions found.\n")
        }
        
        let pathBuffer = try Double(string: terminal.ask("Path buffer distance (m)?"))
        if let paths = try kmlManager.getPaths(buffer: pathBuffer) {
            terminal.output("\(paths.count)".consoleText(color: .magenta) + " paths found.\n".consoleText())
            
            let pMin = try Int(string: terminal.ask("Min zoom for paths?"))
            let pMax = try Int(string: terminal.ask("Max zoom for paths?"))
            
            var pathTiles = tileManager.calculateTileLocations(along: paths, minZ: pMin, maxZ: pMax, buffer: pathBuffer)
            
            var skipping = false
            if terminal.confirm("Skip every second zoom level?") {
                skipping = true
                let zooms = Array(pMin...pMax)
                let filteredZooms = zooms.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
                pathTiles = pathTiles.filter { filteredZooms.contains($0.z) }
            }
            
            let pathTileSet = Set(pathTiles)
            tileSet = tileSet.union(pathTileSet)
            
            let summary: ConsoleText =
                "\(paths.count)".consoleText(color: .cyan) +
                " path(s) - Min/Max Zoom: " +
                "\(pMin)".consoleText(color: .cyan) +
                " / " +
                "\(pMax)".consoleText(color: .cyan) +
                " - TILES: ".consoleText() +
                "\(pathTileSet.count)".consoleText(color: .cyan) +
                "\(skipping ? " (skipping every second layer)\n": "\n")".consoleText()
            
            terminal.output(summary)
        } else {
            terminal.output("No paths found.")
        }
        
        let tiles = Array(tileSet)
        
        let sizeString = sizeForCount(tileCount: tiles.count)
        let dbPath = "\(kmlPath.path.dirname)/\(kmlPath.path.basename.components(separatedBy: ".")[0]).sqlite"

        if !terminal.confirm("Download will grab \(sizeString) to \(dbPath). Continue?".consoleText()) {
            terminal.output("Oh well, maybe another time.")
            return
        }
        
        let dataManager = try DatabaseManager(path: dbPath, deletingIfExists: true, terminal: terminal)
        try dataManager.migrateDatabase()
        try dataManager.insertLocations(tiles)
        
        let downloadManager = DownloadManager(databaseManager: dataManager, terminal: terminal)
        
        let group = DispatchGroup()
        downloadManager.fetchMap(tiles: tiles, group: group, provider: GoogleProvider())
        group.wait()
        
        terminal.output("Download Complete".consoleText(color: .green))
        
        try dataManager.vacuumDatase()
    }
}
