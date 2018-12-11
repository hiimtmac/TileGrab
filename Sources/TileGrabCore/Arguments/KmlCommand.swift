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
    let prettyPrintArg: OptionArgument<Bool>
    
    init(parser: ArgumentParser, terminal: Terminal) {
        let subparser = parser.add(subparser: command, overview: overview)
        self.kmlPathArg = subparser.add(option: "--attribute-file", shortName: "-a", kind: PathArgument.self, usage: "Path to kml file with regions", completion: .filename)
        self.prettyPrintArg = subparser.add(option: "--pretty-print", shortName: "-p", kind: Bool.self, usage: "Ouput pretty printed")
        self.terminal = terminal
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let kmlPath: PathArgument
        let prettyPrint: Bool
        if let regionsFile = arguments.get(kmlPathArg) {
            kmlPath = regionsFile
            prettyPrint = arguments.get(prettyPrintArg) ?? false
        } else {
            kmlPath = try PathArgument(argument: terminal.ask("Path for attributes file? (kml)"))
            prettyPrint = terminal.confirm("Pretty print output json?")
        }
        
        let jsonPath = "\(kmlPath.path.dirname)/\(kmlPath.path.basename.components(separatedBy: ".")[0]).json"
        if FileManager.default.fileExists(atPath: jsonPath) {
            let url = URL(fileURLWithPath: jsonPath)
            try?  FileManager.default.removeItem(at: url)
        }

        let kmlManager = try KMLManager(kmlPath: kmlPath.path.asString, terminal: terminal)        
        let data = try kmlManager.encode(pretty: prettyPrint)

        terminal.output("\(prettyPrint ? "Pretty printed o": "O")utput created successfully: ".consoleText(), newLine: false)
        if FileManager.default.createFile(atPath: jsonPath, contents: data, attributes: nil) {
            terminal.output("TRUE".consoleText(color: .green))
        } else {
            terminal.output("FALSE".consoleText(color: .red))
        }
    }
}

