import Foundation
import CoreData

/// Manages meetings within a project.
final class MeetingListViewModel: ObservableObject {
    @Published var meetings: [Meeting] = []
    private let context: NSManagedObjectContext
    /// Project whose meetings are being managed. Exposed for view usage.
    let project: Project
    private let persistence = PersistenceController.shared

    init(project: Project, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.project = project
        self.context = context
        fetchMeetings()
    }

    /// Fetch all meetings for the current project.
    func fetchMeetings() {
        let request = Meeting.fetchRequest()
        request.predicate = NSPredicate(format: "project == %@", project)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Meeting.date, ascending: true)]
        meetings = (try? context.fetch(request)) ?? []
    }

    /// Create a new meeting for the project.
    func addMeeting(title: String, date: Date) {
        let meeting = Meeting(context: context)
        meeting.title = title
        meeting.date = date
        meeting.project = project
        persistence.save(context: context)
        fetchMeetings()
    }
}
