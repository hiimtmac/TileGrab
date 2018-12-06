//
//  TilePath.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-06.
//

import Foundation
import CoreLocation

struct TilePath {
    let coordinates: [CLLocationCoordinate2D]
    
    init(coordinates: [CLLocationCoordinate2D], buffer: Double) {
        var adjustedCoordinates = coordinates
        for (index, coordinate) in coordinates.enumerated() {
            if index == 0 { continue }
            
            let previous = coordinates[index - 1]
            let p1 = CLLocation(latitude: previous.latitude, longitude: previous.longitude)
            let p2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            let distance = p1.distance(from: p2)
            if distance >= buffer {
                let pointsToAdd = Int(ceil(distance / buffer)) - 1
                let xDiff = coordinate.longitude - previous.longitude
                let yDiff = coordinate.latitude - previous.latitude
                for i in 1...pointsToAdd {
                    let ratio = Double(i) / Double(pointsToAdd)
                    let xDelt = xDiff * ratio
                    let yDelt = yDiff * ratio
                    
                    let new = CLLocationCoordinate2D(latitude: previous.latitude + yDelt, longitude: previous.longitude + xDelt)
                    adjustedCoordinates.append(new)
                }
            }
        }
        
        self.coordinates = adjustedCoordinates
    }
    
    func tiles(minZ: Int, maxZ: Int, buffer: Double) -> Set<DBTile> {
        var locations = Set<DBTile>()

        for coordinate in coordinates {
            let x = getXTile(location: coordinate, at: minZ)
            let y = getYTile(location: coordinate, at: minZ)
            let tile = DBTile(x: x, y: y, z: minZ)
            locations.insert(tile)
            
            if tile.leftBuffer(for: coordinate) < buffer {
                let leftCoord = getCoordinate(distance: buffer, from: coordinate, deg: 270)
                let leftX = getXTile(location: leftCoord, at: minZ)
                for newX in leftX...x {
                    let t = DBTile(x: newX, y: y, z: minZ)
                    locations.insert(t)
                }
            }
            if tile.rightBuffer(for: coordinate) < buffer {
                let rightCoord = getCoordinate(distance: buffer, from: coordinate, deg: 90)
                let rightX = getXTile(location: rightCoord, at: minZ)
                for newX in x...rightX {
                    let t = DBTile(x: newX, y: y, z: minZ)
                    locations.insert(t)
                }
            }
            if tile.topBuffer(for: coordinate) < buffer {
                let topCoord = getCoordinate(distance: buffer, from: coordinate, deg: 0)
                let topY = getYTile(location: topCoord, at: minZ)
                for newY in topY...y {
                    let t = DBTile(x: x, y: newY, z: minZ)
                    locations.insert(t)
                }
            }
            if tile.bottomBuffer(for: coordinate) < buffer {
                let botCoord = getCoordinate(distance: buffer, from: coordinate, deg: 180)
                let botY = getYTile(location: botCoord, at: minZ)
                for newY in y...botY {
                    let t = DBTile(x: x, y: newY, z: minZ)
                    locations.insert(t)
                }
            }
        }
        
        return locations.reduce(locations, { $0.union($1.children(max: maxZ)) })
    }
}
