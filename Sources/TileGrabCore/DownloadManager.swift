//
//  DownloadManager.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import GRDB
import Console

class DownloadManager {
    let databaseManager: DatabaseManager
    let terminal: Terminal
    
    init(databaseManager: DatabaseManager, terminal: Terminal) {
        self.databaseManager = databaseManager
        self.terminal = terminal
    }
    
    func fetchMap(tiles: [DBTile], group: DispatchGroup) {
        let tileCount = tiles.count
        terminal.output("Fetching \(tileCount) tiles...".consoleText())
        
        for (index, tile) in tiles.enumerated() {
            group.enter()
            
            URLSession.shared.dataTask(with: tile.url) { [unowned self] (data, response, error) in
                defer {
                    group.leave()
                }
                
                if let error = error {
                    let errorMessage: ConsoleText =
                        "Error".consoleText(color: .red, isBold: true) +
                        " \(index + 1) of \(tileCount): \(tile.display)".consoleText() +
                        " - \(error.localizedDescription)".consoleText()
                    self.terminal.output(errorMessage)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let errorMessage: ConsoleText =
                        "Error".consoleText(color: .red, isBold: true) +
                            " \(index + 1) of \(tileCount): \(tile.display)".consoleText() +
                            " - No Response".consoleText()
                    self.terminal.output(errorMessage)
                    return
                }
                
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    let errorMessage: ConsoleText =
                        "Error".consoleText(color: .red, isBold: true) +
                            " \(index + 1) of \(tileCount): \(tile.display)".consoleText() +
                            " - Bad Status: \(httpResponse.statusCode)".consoleText()
                    self.terminal.output(errorMessage)
                    return
                }
                
                do {
                    tile.data = data
                    try self.databaseManager.persist(tile: tile)
                    self.terminal.output("Success".consoleText(color: .green) + " \(index + 1) of \(tileCount): \(tile.display)".consoleText())
                } catch {
                    let errorMessage: ConsoleText =
                        "Error".consoleText(color: .red, isBold: true) +
                            " \(index + 1) of \(tileCount): \(tile.display)".consoleText() +
                            " - \(error.localizedDescription)".consoleText()
                    self.terminal.output(errorMessage)
                }
                }.resume()
        }
    }
}
