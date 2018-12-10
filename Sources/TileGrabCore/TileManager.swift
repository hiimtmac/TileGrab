//
//  TileManager.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-11-30.
//

import Foundation
import GRDB
import Console

class TileManager {
    func calculateTileLocations(for regions: [TileRegion], minZ: Int, maxZ: Int, buffer: Double) -> [DBTile] {
        let tiles = regions.reduce(Set<DBTile>()) { tiles, region -> Set<DBTile> in
            let regionTiles = region.tiles(minZ: minZ, maxZ: maxZ, buffer: buffer)
            return tiles.union(regionTiles)
        }
        return Array(tiles)
    }
    
    func calculateTileLocations(along paths: [TilePath], minZ: Int, maxZ: Int, buffer: Double) -> [DBTile] {
        let tiles = paths.reduce(Set<DBTile>()) { tiles, path -> Set<DBTile> in
            let pathTiles = path.tiles(minZ: minZ, maxZ: maxZ, buffer: buffer)
            return tiles.union(pathTiles)
        }
        return Array(tiles)
    }
}
