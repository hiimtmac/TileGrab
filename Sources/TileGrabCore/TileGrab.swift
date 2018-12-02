import Foundation
import GRDB
import Console

public final class TileGrab {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        let terminal = Terminal()

        guard
            arguments.count >= 3,
            arguments[1] == "--name"
        else {
            throw Error.badInput
        }
        
        let name = arguments[2]
        
        let tl: String
        if arguments.count >= 5, arguments[3] == "--top-left" {
            tl = arguments[4]
        } else {
            tl = terminal.ask("Top left coordinate (lat,long):")
        }
        
        let tlCoord = try Coordinate(input: tl)
        
        let br: String
        if arguments.count >= 7, arguments[5] == "--bottom-right" {
            br = arguments[6]
        } else {
            br = terminal.ask("Bottom right coordinate (lat,long):")
        }

        let brCoord = try Coordinate(input: br)
        
        let minZ: Int
        if arguments.count >= 9, arguments[7] == "--min-zoom" {
            minZ = Int(arguments[8])!
        } else {
            minZ = Int(terminal.ask("Minimum Zoom:"))!
        }
        
        let maxZ: Int
        if arguments.count >= 11, arguments[9] == "--max-zoom" {
            maxZ = Int(arguments[10])!
        } else {
            maxZ = Int(terminal.ask("Maximum Zoom:"))!
        }
        
        let region = try TileRegion(tl: tlCoord, br: brCoord, min: minZ, max: maxZ)
        let tiles = region.tiles()
        
        let sizeString = try sizeForCount(tileCount: tiles.count)
        
        let summary: ConsoleText = "Top Left: " +
            "\(tlCoord.latitude), \(tlCoord.longitude)".consoleText(color: .blue) +
            " - Bottom Right: " +
            "\(brCoord.latitude), \(brCoord.longitude)".consoleText(color: .blue) +
            " - Min Zoom: " +
            "\(minZ)".consoleText(color: .blue) +
            " - Max Zoom: " +
            "\(maxZ)".consoleText(color: .blue)
            
        terminal.output(summary)
        if !terminal.confirm("Download will grab \(sizeString) to ~/Desktop/\(name).sqlite. Continue?".consoleText()) {
            terminal.output("Oh well, maybe another time.")
            return
        }
        
        let tileManager = try TileManager(tiles: tiles, name: name)
        try tileManager.migrateDatabase()

        let group = DispatchGroup()
        tileManager.fetchMap(group: group, terminal: terminal)
        group.wait()
        
        terminal.output("Download Complete".consoleText(color: .green))
        
        try tileManager.vacuumDataase()
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
