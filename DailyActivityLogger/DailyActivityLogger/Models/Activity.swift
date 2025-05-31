import Foundation

struct Activity: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var descriptionText: String? // Optional as per requirements, though the prompt said String
    var date: Date
}
