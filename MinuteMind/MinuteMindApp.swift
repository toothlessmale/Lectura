import SwiftUI

/// Entry point for MinuteMind.
@main
struct MinuteMindApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ProjectListView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
