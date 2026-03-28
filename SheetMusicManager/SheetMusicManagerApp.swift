import SwiftUI
import SwiftData

@main
struct SheetMusicManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [SheetMusic.self, Tag.self])
    }
}
