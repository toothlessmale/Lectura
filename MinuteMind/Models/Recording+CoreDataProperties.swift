import Foundation
import CoreData

extension Recording {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        NSFetchRequest<Recording>(entityName: "Recording")
    }

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date?
    @NSManaged public var duration: Double
    @NSManaged public var audioFileURL: String?
    @NSManaged public var transcript: String?
    @NSManaged public var summary: String?
    @NSManaged public var meeting: Meeting?
}

extension Recording : Identifiable {}
