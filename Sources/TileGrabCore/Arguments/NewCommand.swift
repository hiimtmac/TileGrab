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
    let kmlTypeArg: OptionArgument<KMLType>
    let minZArg: OptionArgument<Int>
    let maxZArg: OptionArgument<Int>
    let skippingZoomsArg: OptionArgument<Bool>
    
    enum KMLType: String, ArgumentKind {
        public init(argument: String) throws {
            guard let type = KMLType(rawValue: argument) else {
                throw Error.unknownType
            }
            self = type
        }
        
        public static let completion: ShellCompletion = .none
        
        case paths
        case regions
        
        enum Error: Swift.Error, LocalizedError {
            case unknownType
            
            var errorDescription: String? {
                switch self {
                case .unknownType: return "Unknown KML Type"
                }
            }
        }
    }
    
    init(parser: ArgumentParser, terminal: Terminal) {
        let subparser = parser.add(subparser: command, overview: overview)
        self.kmlPathArg = subparser.add(option: "--kml", shortName: "-k", kind: PathArgument.self, usage: "Path to kml file.", completion: .filename)
        self.kmlTypeArg = subparser.add(option: "--type", shortName: "-t", kind: KMLType.self, usage: "Type [regions paths]")
        self.minZArg = parser.add(option: "--min", kind: Int.self, usage: "Min Zoom")
        self.maxZArg = parser.add(option: "--max", kind: Int.self, usage: "Max Zoom")
        self.skippingZoomsArg = parser.add(option: "--skipping", shortName: "-s", kind: Bool.self, usage: "Skips every second zoom level")
        self.terminal = terminal
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        guard let kmlType = arguments.get(kmlTypeArg) else {
            throw ArgumentParserError.expectedValue(option: "No/unexpected kml type")
        }
        
        guard let kmlPath = arguments.get(kmlPathArg) else {
            throw ArgumentParserError.expectedValue(option: "Bad path")
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
        
        var tiles = [DBTile]()
        let kmlManager = try KMLManager(kmlPath: kmlPath.path.asString)
        let tileManager = TileManager()

        switch kmlType {
        case .regions:
            let regions = try kmlManager.getRegions()
            tiles = tileManager.calculateTileLocations(for: regions, minZ: minZ, maxZ: maxZ)
            
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
        case .paths:
            let buffer = 100.0
            let paths = try kmlManager.getPaths(buffer: buffer)
            tiles = tileManager.calculateTileLocations(along: paths, minZ: minZ, maxZ: maxZ, buffer: buffer)
            
            let summary: ConsoleText =
                "\(paths.count)".consoleText(color: .blue) +
                    " path(s) - Min/Max Zoom: " +
                    "\(minZ)".consoleText(color: .blue) +
                    " / " +
                    "\(maxZ)".consoleText(color: .blue) +
                    "\(skippingZoom ? " skipping every second layer": "")".consoleText()
            
            terminal.output(summary)
        }
        
        if skippingZoom {
            let zooms = Array(minZ...maxZ)
            let filteredZooms = zooms.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
            tiles = tiles.filter { filteredZooms.contains($0.z) }
        }
        
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
        
        try dataManager.vacuumDataase()
    }
}
