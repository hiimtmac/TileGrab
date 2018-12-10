//
//  DBTile.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-11-30.
//

import Foundation
import CoreLocation

struct TileRegion {
    let tl: CLLocationCoordinate2D
    let br: CLLocationCoordinate2D
    
    func tiles(minZ: Int, maxZ: Int, buffer: Double) -> Set<DBTile> {
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
        
        var locations = Set<DBTile>()
        for x in xrange {
            for y in yrange {
                locations.insert(DBTile(x: x, y: y, z: minZ))
            }
        }
        
        return locations.reduce(locations, { $0.union($1.children(max: maxZ)) })
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
}
