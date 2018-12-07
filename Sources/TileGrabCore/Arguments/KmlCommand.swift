//
//  KmlCommand.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import Console
import Utility

struct KmlCommand: Command {
    
    let command = "kml"
    let overview = "Get kml attributes into database"
    
    let terminal: Terminal
    let kmlPathArg: OptionArgument<PathArgument>
    
    init(parser: ArgumentParser, terminal: Terminal) {
        let subparser = parser.add(subparser: command, overview: overview)
        self.kmlPathArg = subparser.add(option: "--attribute-file", shortName: "-a", kind: PathArgument.self, usage: "Path to kml file with regions", completion: .filename)
        self.terminal = terminal
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let kmlPath: PathArgument
        if let regionsFile = arguments.get(kmlPathArg) {
            kmlPath = regionsFile
        } else {
            kmlPath = try PathArgument(argument: terminal.ask("Path for attributes file? (kml)"))
        }
        
        let jsonPath = "\(kmlPath.path.dirname)/\(kmlPath.path.basename.components(separatedBy: ".")[0]).json"

        let kmlManager = try KMLManager(kmlPath: kmlPath.path.asString)
        kmlManager.makeDocument()
    }
}

