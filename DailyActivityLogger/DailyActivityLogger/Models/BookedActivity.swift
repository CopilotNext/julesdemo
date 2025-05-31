import Foundation

struct BookedActivity: Codable, Identifiable {
    var id: UUID = UUID()
    var activityName: String
    var date: Date
    var notes: String?
}
