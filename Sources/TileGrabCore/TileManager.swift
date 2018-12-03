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
    let regions: [TileRegion]
    let terminal: Terminal
    
    init(regions: [TileRegion], terminal: Terminal) {
        self.regions = regions
        self.terminal = terminal
    }
    
    func getTileLocations() -> [Tile] {
        let tiles = regions.reduce(Set<Tile>()) { tiles, region -> Set<Tile> in
            let regionTiles = region.tiles()
            return tiles.union(regionTiles)
        }
        return Array(tiles)
    }
}
