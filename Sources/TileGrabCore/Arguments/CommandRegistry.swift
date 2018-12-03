//
//  CommandRegistry.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import Utility
import Console
import Basic

struct CommandRegistry {
    
    let terminal: Terminal
    let parser: ArgumentParser
    let arguments: [String]
    var commands: [Command] = []
    
    init(usage: String, overview: String, arguments: [String], terminal: Terminal) {
        self.parser = ArgumentParser(usage: usage, overview: overview)
        self.arguments = arguments
        self.terminal = terminal
    }
    
    mutating func register(command: Command.Type) {
        commands.append(command.init(parser: parser, terminal: terminal))
    }
    
    func run() {
        do {
            let droppedArguments = Array(arguments.dropFirst())
            let parsedArguments = try parser.parse(droppedArguments)
            try process(arguments: parsedArguments)
        } catch let error as ArgumentParserError {
            terminal.output("Error:".consoleText(color: .red) + " \(error.description)".consoleText())
        } catch {
            terminal.output("Error:".consoleText(color: .red) + " \(error.localizedDescription)".consoleText())
        }
    }
    
    private func process(arguments: ArgumentParser.Result) throws {
        guard let subparser = arguments.subparser(parser),
            let command = commands.first(where: { $0.command == subparser }) else {
                parser.printUsage(on: stdoutStream)
                return
        }
        try command.run(with: arguments)
    }
}
