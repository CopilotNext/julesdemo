import XCTest
@testable import DailyActivityLogger

class BookedActivityModelTests: XCTestCase {

    func testBookedActivityEncodingDecoding() throws {
        // Given
        let id = UUID()
        let date = Date()
        let originalBookedActivity = BookedActivity(id: id, activityName: "Team Meeting", date: date, notes: "Discuss project milestones")

        // When
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalBookedActivity)

        let decoder = JSONDecoder()
        let decodedBookedActivity = try decoder.decode(BookedActivity.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedBookedActivity.id, originalBookedActivity.id)
        XCTAssertEqual(decodedBookedActivity.activityName, originalBookedActivity.activityName)
        XCTAssertEqual(decodedBookedActivity.notes, originalBookedActivity.notes)
        XCTAssertEqual(decodedBookedActivity.date.timeIntervalSince1970, originalBookedActivity.date.timeIntervalSince1970, accuracy: 0.001)
    }

    func testBookedActivityOptionalNotesEncodingDecoding() throws {
        // Given
        let id = UUID()
        let date = Date()
        let originalBookedActivity = BookedActivity(id: id, activityName: "Lunch", date: date, notes: nil)

        // When
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalBookedActivity)

        let decoder = JSONDecoder()
        let decodedBookedActivity = try decoder.decode(BookedActivity.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedBookedActivity.id, originalBookedActivity.id)
        XCTAssertEqual(decodedBookedActivity.activityName, originalBookedActivity.activityName)
        XCTAssertNil(decodedBookedActivity.notes, "Notes should be nil")
        XCTAssertEqual(decodedBookedActivity.date.timeIntervalSince1970, originalBookedActivity.date.timeIntervalSince1970, accuracy: 0.001)
    }
}
