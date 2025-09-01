import Foundation
import CoreData

extension Project {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var name: String?
    @NSManaged public var meetings: Set<Meeting>?
}

extension Project : Identifiable {}
