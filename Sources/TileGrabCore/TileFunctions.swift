//
//  TileFunctions.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-11-30.
//

import Foundation

struct Coordinate {
    let latitude: Double
    let longitude: Double
    
    init(input: String) throws {
        let components = input.components(separatedBy: ",")
        guard components.count == 2 else {
            throw Error.invalidComponents
        }
        
        guard let lat = Double(components[0]) else {
            throw Error.invalidLatitude
        }
        
        guard let long = Double(components[1]) else {
            throw Error.invalidLongitude
        }
        
        self.latitude = lat
        self.longitude = long
    }
    
    func tileLocation(at coordinate: Coordinate, for zoom: Int) -> TileLocation {
        let x = getXTile(location: coordinate, at: zoom)
        let y = getXTile(location: coordinate, at: zoom)
        return TileLocation.init(x: x, y: y, z: zoom)
    }
    
    enum Error: Swift.Error {
        case invalidComponents
        case invalidLatitude
        case invalidLongitude
    }
}

func getXTile(location: Coordinate, at zoom: Int) -> Int {
    let arg: Double = (location.longitude + 180)/360
    let powx: Double = pow(Double(2),Double(zoom))
    return Int(floor(arg * powx))
}

func getYTile(location: Coordinate, at zoom: Int) -> Int {
    let tanx = tan(location.latitude * (Double.pi / 180))
    let cosx = 1 / cos(location.latitude * (Double.pi / 180))
    let lnx = log(tanx + cosx)
    let pix = lnx / Double.pi
    let powx = pow(Double(2),Double(zoom - 1))
    return Int(floor((1 - pix) * powx))
}

//func combinations(xs: [Int], ys: [Int], at zoom: Int) -> Set<TileLocation> {
//    var tileSet: Set<TileLocation> = []
//
//    for x in xs {
//        for y in ys {
//            let tile = TileLocation(x: x, y: y, z: zoom)
//            tileSet.insert(tile)
//        }
//    }
//
//    return tileSet
//}
