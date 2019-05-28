//
//  Command.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import SPMUtility
import Console

protocol Command {
    var command: String { get }
    var overview: String { get }
    
    init(parser: ArgumentParser, terminal: Terminal)
    func run(with arguments: ArgumentParser.Result) throws
}
