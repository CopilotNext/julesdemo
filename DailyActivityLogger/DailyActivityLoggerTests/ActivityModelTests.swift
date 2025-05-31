import XCTest
@testable import DailyActivityLogger // Allows access to internal types if needed

class ActivityModelTests: XCTestCase {

    func testActivityEncodingDecoding() throws {
        // Given
        let id = UUID()
        let date = Date()
        let originalActivity = Activity(id: id, name: "Morning Run", descriptionText: "5km run in the park", date: date)

        // When
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalActivity)

        let decoder = JSONDecoder()
        let decodedActivity = try decoder.decode(Activity.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedActivity.id, originalActivity.id)
        XCTAssertEqual(decodedActivity.name, originalActivity.name)
        XCTAssertEqual(decodedActivity.descriptionText, originalActivity.descriptionText)
        // Comparing dates can be tricky due to precision. Compare timeIntervalSince1970 for robustness.
        XCTAssertEqual(decodedActivity.date.timeIntervalSince1970, originalActivity.date.timeIntervalSince1970, accuracy: 0.001)
    }

    func testActivityOptionalDescriptionEncodingDecoding() throws {
        // Given
        let id = UUID()
        let date = Date()
        let originalActivity = Activity(id: id, name: "Reading", descriptionText: nil, date: date)

        // When
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalActivity)

        let decoder = JSONDecoder()
        let decodedActivity = try decoder.decode(Activity.self, from: encodedData)

        // Then
        XCTAssertEqual(decodedActivity.id, originalActivity.id)
        XCTAssertEqual(decodedActivity.name, originalActivity.name)
        XCTAssertNil(decodedActivity.descriptionText, "Description text should be nil")
        XCTAssertEqual(decodedActivity.date.timeIntervalSince1970, originalActivity.date.timeIntervalSince1970, accuracy: 0.001)
    }
}
