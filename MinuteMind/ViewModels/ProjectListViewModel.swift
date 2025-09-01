import Foundation
import CoreData

/// ViewModel responsible for listing and creating projects.
final class ProjectListViewModel: ObservableObject {
    @Published var projects: [Project] = []
    private let context: NSManagedObjectContext
    private let persistence = PersistenceController.shared

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchProjects()
    }

    /// Fetch all projects from storage.
    func fetchProjects() {
        let request = Project.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.name, ascending: true)]
        projects = (try? context.fetch(request)) ?? []
    }

    /// Create a new project with the given name.
    func addProject(name: String) {
        let project = Project(context: context)
        project.name = name
        persistence.save(context: context)
        fetchProjects()
    }
}
