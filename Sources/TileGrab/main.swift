import TileGrabCore

let tool = TileGrab()

do {
    try tool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
