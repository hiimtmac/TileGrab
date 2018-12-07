import Foundation
import Console
import Utility

public final class TileGrab {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        let terminal = Terminal()
        
        var registry = CommandRegistry(usage: "<command> <options>", overview: "Tile Grab", arguments: arguments, terminal: terminal)
        
        registry.register(command: NewCommand.self)
        registry.register(command: FillCommand.self)
        registry.register(command: KmlCommand.self)
        registry.register(command: InfoCommand.self)

        registry.run()
        
        terminal.print("Done, thanks for playing!\n")
    }
}
