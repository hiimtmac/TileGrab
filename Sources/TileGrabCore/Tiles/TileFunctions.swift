//
//  TileFunctions.swift
//  Async
//
//  Created by Taylor McIntyre on 2018-11-30.
//

import Foundation
import CoreLocation

func getXTile(location: CLLocationCoordinate2D, at zoom: Int) -> Int {
    let z = Double(zoom)
    let x = location.longitude
    let loc = ((x + 180) / 360) * pow(2.0, z)
    return Int(floor(loc))
}

func getYTile(location: CLLocationCoordinate2D, at zoom: Int) -> Int {
    let π = Double.pi
    let z = Double(zoom - 1)
    let y = location.latitude

    let tanx = tan(y * (π / 180))
    let cosx = 1 / cos(y * (π / 180))
    let lnx = log(tanx + cosx)
    let pix = lnx / π

    let loc = (1 - pix) * pow(2.0, z)
    return Int(floor(loc))
}

func getCoordinate(x: Int, y: Int, zoom: Int) -> CLLocationCoordinate2D {
    let π = Double.pi
    let x = Double(x)
    let y = Double(y)
    let z = Double(zoom)
    
    let lon = ((x / (pow(2.0, z))) * 360) - 180
    let lat = (180.0 / π) * atan(sinh(π * (1 - (2.0 * y / pow(2.0, z)))))
    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
}

func getCoordinate(distance: CLLocationDistance, from: CLLocationCoordinate2D, deg: Double) -> CLLocationCoordinate2D {
    let π = Double.pi
    let r = 6371.0
    let d = distance / 1000.0
    
    let latRad1 = from.latitude * π / 180.0
    let lonRad1 = from.longitude * π / 180.0
    let b = deg * π / 180.0
    
    let latRad2 = asin(sin(latRad1) * cos(d / r) + cos(latRad1) * sin(d / r) * cos(b))
    let lonRad2 = lonRad1 + atan2(sin(b) * sin(d / r) * cos(latRad1), cos(d / r) - sin(latRad1) * sin(latRad2))
    
    let latDeg = latRad2 * 180 / π
    let lonDeg = lonRad2 * 180 / π
    
    return CLLocationCoordinate2D(latitude: latDeg, longitude: lonDeg)
}

func sizeForCount(tileCount: Int) -> String {
    guard tileCount > 0 else {
        return "No tiles."
    }
    
    let avgByteSize = 15000.0
    let sizes = ["Bytes", "KB", "MB", "GB", "TB"]
    
    let bytes = avgByteSize * Double(tileCount)
    
    let sizeIndex = Int(floor(log(bytes)) / log(1024.0))
    let sizeString = sizes[sizeIndex]
    let sizeDec = Decimal(bytes) / pow(1024, sizeIndex)
    let sizeDoub = NSDecimalNumber(decimal: sizeDec).doubleValue
    let sizeValue = round(sizeDoub)
    
    return "~\(tileCount) tiles @ estimated ~\(sizeValue) \(sizeString)"
}
