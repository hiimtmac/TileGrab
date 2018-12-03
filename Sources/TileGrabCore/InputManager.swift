//
//  InputManager.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import Console
import CoreLocation
import Utility

struct InputManager {
    let arguments: [String]
    let name: String
    let path: String
    let min: Int
    let max: Int
    let skips: Bool
    let regions: [TileRegion]
    
    init(arguments: [String], terminal: Terminal) throws {
        self.arguments = arguments
        
        let parser = ArgumentParser(commandName: "TileGrab", usage: "filename [--regions ~/Desktop/regions.kml]", overview: "Grabs tiles from google maps for offline viewing.")
        let regionsInput = parser.add(option: "--regions", shortName: "-r", kind: PathArgument.self, usage: "CSV containing region information", completion: .filename)
        let maxInput = parser.add(option: "--max", kind: Int.self, usage: "Max Zoom")
        let minInput = parser.add(option: "--min", kind: Int.self, usage: "Min Zoom")
        let skipping = parser.add(option: "--skipping", shortName: "-s", kind: Bool.self, usage: "Skips every second zoom level")

        let args = Array(arguments.dropFirst())
        let result = try parser.parse(args)
        
        let pathArg: PathArgument
        if let regionsFile = result.get(regionsInput) {
            pathArg = regionsFile
        } else {
            pathArg = try PathArgument(argument: terminal.ask("Path for regions file?"))
        }
        
        let minArg: Int
        if let min = result.get(minInput) {
            minArg = min
        } else {
            minArg = Int(terminal.ask("Min Zoom"))!
        }
        
        let maxArg: Int
        if let max = result.get(maxInput) {
            maxArg = max
        } else {
            maxArg = Int(terminal.ask("Max Zoom"))!
        }

        if !FileManager.default.fileExists(atPath: pathArg.path.asString) {
            throw Error.missingFile
        }
        
        let url = URL(fileURLWithPath: pathArg.path.asString)
        let data = try Data(contentsOf: url)
        
        let xmlManager = XMLManager(data: data)

        self.name = pathArg.path.basename.components(separatedBy: ".").first!
        self.path = pathArg.path.dirname
        self.min = minArg
        self.max = maxArg
        self.skips = result.get(skipping) ?? false
        self.regions = try xmlManager.getRegions(min: min, max: max)
    }
    
    enum Error: Swift.Error {
        case missingFile
        case badComponent(Int)
    }
}
