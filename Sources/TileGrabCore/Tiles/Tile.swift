//
//  Tile.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-11-30.
//

import Foundation
import GRDB
import CoreLocation

struct TileRegion {
    let tl: CLLocationCoordinate2D
    let br: CLLocationCoordinate2D
    let minZ: Int
    let maxZ: Int
    
    init(tl: CLLocationCoordinate2D, br: CLLocationCoordinate2D, min: Int, max: Int) throws {
        guard tl.longitude < br.longitude else {
            throw Error.coordinateError("Longitude of top left must be smaller than bottom right")
        }
        
        guard tl.latitude > br.latitude else {
            throw Error.coordinateError("Latitude of top left must be larger than bottom right")
        }
        
        guard min < max else {
            throw Error.zoomError
        }
        
        self.tl = tl
        self.br = br
        self.minZ = min
        self.maxZ = max
    }
    
    func tiles() -> Set<Tile> {
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
        
        var locations = [Tile]()
        for x in xrange {
            for y in yrange {
                locations.append(Tile(x: x, y: y, z: minZ))
            }
        }
        
        let tiles = locations.reduce(locations, { $0 + $1.children(max: maxZ) })
        return Set(tiles)
    }
    
    var squareKM: Double {
        let latFrom = CLLocation(latitude: tl.latitude, longitude: tl.longitude)
        let latTo = CLLocation(latitude: br.latitude, longitude: tl.longitude)
        let lat = latFrom.distance(from: latTo) / 1000
        
        let lonFrom = CLLocation(latitude: tl.latitude, longitude: tl.longitude)
        let lonTo = CLLocation(latitude: tl.latitude, longitude: br.longitude)
        let lon = lonFrom.distance(from: lonTo) / 1000
        
        return round(lat * lon)
    }
    
    enum Error: Swift.Error {
        case coordinateError(String)
        case zoomError
    }
}
