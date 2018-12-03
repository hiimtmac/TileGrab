import Foundation
import GRDB
import Console
import CoreLocation

public final class TileGrab {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        let terminal = Terminal()
        
        let inputManager = try InputManager(arguments: arguments, terminal: terminal)
        
        let dataManager = try DatabaseManager(name: inputManager.name, path: inputManager.path)
        try dataManager.migrateDatabase()
        
        let tileCount = try dataManager.tileCount()
        if tileCount == 0 {
            terminal.output("Calculating tiles...")
            let tileManager = TileManager(regions: inputManager.regions, terminal: terminal)
            var tiles = tileManager.getTileLocations()
            
            if inputManager.skips {
                let zooms = Array(inputManager.min...inputManager.max)
                let filteredZooms = zooms.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
                tiles = tiles.filter { filteredZooms.contains($0.z) }
            }
            
            try dataManager.insertLocations(tiles)
            
            let summary: ConsoleText =
                "\(inputManager.regions.count)".consoleText(color: .blue) +
                    " region(s) covering ~" +
                    "\(inputManager.regions.reduce(0, { $0 + $1.squareKM }))".consoleText(color: .blue) +
                    " square km - Min/Max Zoom: " +
                    "\(inputManager.min)".consoleText(color: .blue) +
                    " / " +
                    "\(inputManager.max)".consoleText(color: .blue) +
                    "\(inputManager.skips ? " skipping every second layer": "")".consoleText()
            
            terminal.output(summary)
        }
        
        let tilesToFetch = try dataManager.tileWithoutData()
        
        let sizeString = try sizeForCount(tileCount: tilesToFetch.count)

        if !terminal.confirm("Download will grab \(sizeString) to \(inputManager.path)/\(inputManager.name).sqlite. Continue?".consoleText()) {
            terminal.output("Oh well, maybe another time.")
            return
        }
        
        let downloadManager = DownloadManager(databaseManager: dataManager, terminal: terminal)
        let group = DispatchGroup()
        downloadManager.fetchMap(tiles: tilesToFetch, group: group)
        group.wait()

        terminal.output("Download Complete".consoleText(color: .green))

        try dataManager.vacuumDataase()
        terminal.output("Vacuum Complete".consoleText(color: .green))

        terminal.print("Done, thanks for playing!")
    }
    
    func sizeForCount(tileCount: Int) throws -> String {
        guard tileCount > 0 else {
            throw Error.noTiles
        }
        
        let avgByteSize = 15000.0
        let sizes = ["Bytes", "KB", "MB", "GB", "TB"]
        
        let bytes = avgByteSize * Double(tileCount)
        
        let sizeIndex = Int(floor(log(bytes)) / log(1024.0))
        let sizeString = sizes[sizeIndex]
        let sizeDec = Decimal(bytes) / pow(1024, sizeIndex)
        let sizeDoub = NSDecimalNumber(decimal: sizeDec).doubleValue
        let sizeValue = round(sizeDoub)
        
        return "\(tileCount) tiles @ estimated \(sizeValue) \(sizeString)"
    }
    
    enum Error: Swift.Error {
        case badInput
        case noName
        case noTiles
    }
}
