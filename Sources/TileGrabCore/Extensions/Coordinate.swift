//
//  Coordinate.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    init(_ kmlCoordinates: String) {
        let components = kmlCoordinates.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",")
        let latitude = Double(components[1])!
        let longitude = Double(components[0])!
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D: Encodable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
