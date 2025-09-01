import Foundation
import CoreData

/// Performs transcript search across all recordings.
final class SearchViewModel: ObservableObject {
    @Published var query: String = "" {
        didSet { search() }
    }
    @Published var results: [Recording] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    /// Search for query within transcripts.
    func search() {
        guard !query.isEmpty else { results = []; return }
        let request = Recording.fetchRequest()
        request.predicate = NSPredicate(format: "transcript CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recording.timestamp, ascending: false)]
        results = (try? context.fetch(request)) ?? []
    }
}
