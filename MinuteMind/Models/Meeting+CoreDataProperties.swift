import Foundation
import CoreData

extension Meeting {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meeting> {
        NSFetchRequest<Meeting>(entityName: "Meeting")
    }

    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var project: Project?
    @NSManaged public var recordings: Set<Recording>?
}

extension Meeting : Identifiable {}
