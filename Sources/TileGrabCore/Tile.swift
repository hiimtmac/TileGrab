//
//  Tile.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-11-30.
//

import Foundation
import GRDB

struct TileRegion {
    let tl: Coordinate
    let br: Coordinate
    let minZ: Int
    let maxZ: Int
    
    init(tl: Coordinate, br: Coordinate, min: Int, max: Int) throws {
        guard tl.longitude < br.longitude else {
            throw Error.coordinateError("Longitude")
        }
        
        guard tl.latitude > br.latitude else {
            throw Error.coordinateError("Latitude")
        }
        
        guard min < max else {
            throw Error.zoomError
        }
        
        self.tl = tl
        self.br = br
        self.minZ = min
        self.maxZ = max
    }
    
    func tiles() -> Set<TileLocation> {
        let y1 = getYTile(location: tl, at: minZ)
        let x1 = getXTile(location: tl, at: minZ)

        let y2 = getYTile(location: br, at: minZ)
        let x2 = getXTile(location: br, at: minZ)
        
        let minX = min(x1, x2)
        let maxX = max(x1, x2)
        
        let minY = min(y1, y2)
        let maxY = max(y1, y2)
        
        let xrange = minX...maxX
        let yrange = minY...maxY
        
        var locations = [TileLocation]()
        for x in xrange {
            for y in yrange {
                locations.append(TileLocation(x: x, y: y, z: minZ))
            }
        }
        
        let tiles = locations.reduce(locations, { $0 + $1.children(max: maxZ) })
        return Set(tiles)
    }
    
    enum Error: Swift.Error {
        case coordinateError(String)
        case zoomError
    }
}

struct Tile {
    let location: TileLocation
    let data: TileData
    
    var output: TileOutput {
        return TileOutput(x: location.x, y: location.y, z: location.z, data: data.data)
    }
}

struct TileLocation: Hashable {
    let x: Int
    let y: Int
    let z: Int
    
    var slug: String {
        return "x=\(x)&y=\(y)&z=\(z)"
    }
    
    var url: URL {
        return URL(string: "https://mt.google.com/vt/lyrs=s&\(slug)")!
    }
    
    var hashValue: Int {
        return slug.hashValue
    }
    
    var display: String {
        return "x=\(x) y=\(y) z=\(z)"
    }

    func children(max: Int) -> [TileLocation] {
        if z + 1 > max {
            return []
        }

        let x1y1 = TileLocation(x: x * 2, y: y * 2, z: z + 1)
        let x1y2 = TileLocation(x: x * 2, y: y * 2 + 1, z: z + 1)
        let x2y1 = TileLocation(x: x * 2 + 1, y: y * 2, z: z + 1)
        let x2y2 = TileLocation(x: x * 2 + 1, y: y * 2 + 1, z: z + 1)

        let children = [x1y1, x1y2, x2y1, x2y2]
        return children.reduce(children, { $0 + $1.children(max: max) })
    }
}

struct TileData {
    let data: Data
}

struct TileOutput {
    let x: Int
    let y: Int
    let z: Int
    let data: Data
}

extension TileOutput: PersistableRecord {
    enum Columns: String, ColumnExpression {
        case x
        case y
        case z
        case data
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.x] = x
        container[Columns.y] = y
        container[Columns.z] = z
        container[Columns.data] = data
    }
}

extension TileOutput: TableRecord {
    static let databaseTableName = "tiles"
}
