//
//  DownloadManager.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-03.
//

import Foundation
import GRDB
import Console

protocol DownloadProvider {
    func url(x: Int, y: Int, z: Int) -> URL
    var baseURL: URL { get }
}

struct GoogleProvider: DownloadProvider {
    func url(x: Int, y: Int, z: Int) -> URL {
        return baseURL.appendingPathComponent("lyrs=s&x=\(x)&y=\(y)&z=\(z)")
    }
    
    var baseURL: URL {
        return URL(string: "https://mt.google.com/vt")!
    }
}

class DownloadManager {
    let databaseManager: DatabaseManager
    let terminal: Terminal
    
    init(databaseManager: DatabaseManager, terminal: Terminal) {
        self.databaseManager = databaseManager
        self.terminal = terminal
    }
    
    func fetchMap(tiles: [DBTile], group: DispatchGroup, provider: DownloadProvider) {
        let tileCount = tiles.count
        terminal.output("Fetching \(tileCount) tiles...".consoleText())
        
        for (index, tile) in tiles.enumerated() {
            group.enter()
            
            let url = provider.url(x: tile.x, y: tile.y, z: tile.z)
            URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
                defer {
                    group.leave()
                }
                
                if let error = error {
                    let errorMessage: ConsoleText =
                        "Error".consoleText(color: .red, isBold: true) +
                        " \(index + 1) of \(tileCount): \(tile.slug)".consoleText() +
                        " - \(error.localizedDescription)".consoleText()
                    self.terminal.output(errorMessage)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let errorMessage: ConsoleText =
                        "Error".consoleText(color: .red, isBold: true) +
                            " \(index + 1) of \(tileCount): \(tile.slug)".consoleText() +
                            " - No Response".consoleText()
                    self.terminal.output(errorMessage)
                    return
                }
                
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    let errorMessage: ConsoleText =
                        "Error".consoleText(color: .red, isBold: true) +
                            " \(index + 1) of \(tileCount): \(tile.slug)".consoleText() +
                            " - Bad Status: \(httpResponse.statusCode)".consoleText()
                    self.terminal.output(errorMessage)
                    return
                }
                
                do {
                    tile.data = data
                    try self.databaseManager.persist(tile: tile)
                    self.terminal.output("Success".consoleText(color: .green) + " \(index + 1) of \(tileCount): \(tile.slug)".consoleText())
                } catch {
                    let errorMessage: ConsoleText =
                        "Error".consoleText(color: .red, isBold: true) +
                            " \(index + 1) of \(tileCount): \(tile.slug)".consoleText() +
                            " - \(error.localizedDescription)".consoleText()
                    self.terminal.output(errorMessage)
                }
                }.resume()
        }
    }
}
