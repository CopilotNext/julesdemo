import XCTest
@testable import DailyActivityLogger

class PersistenceServiceTests: XCTestCase {

    // Keys used by PersistenceService, ensure they match if not exposed
    private let activitiesKey = "userActivities"
    private let bookedActivitiesKey = "userBookedActivities"

    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: activitiesKey)
        UserDefaults.standard.removeObject(forKey: bookedActivitiesKey)
    }

    override func tearDown() {
        // Clear UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: activitiesKey)
        UserDefaults.standard.removeObject(forKey: bookedActivitiesKey)
        super.tearDown()
    }

    // MARK: - Activity Tests

    func testSaveLoadActivities_Empty() {
        // Given
        let activities: [Activity] = []

        // When
        PersistenceService.saveActivities(activities)
        let loadedActivities = PersistenceService.loadActivities()

        // Then
        XCTAssertTrue(loadedActivities.isEmpty, "Loaded activities should be empty.")
    }

    func testSaveLoadActivities_Single() {
        // Given
        let activity = Activity(name: "Yoga", descriptionText: "Morning session", date: Date())
        let activities = [activity]

        // When
        PersistenceService.saveActivities(activities)
        let loadedActivities = PersistenceService.loadActivities()

        // Then
        XCTAssertEqual(loadedActivities.count, 1)
        XCTAssertEqual(loadedActivities.first?.name, activity.name)
        XCTAssertEqual(loadedActivities.first?.descriptionText, activity.descriptionText)
        XCTAssertEqual(loadedActivities.first?.date.timeIntervalSince1970, activity.date.timeIntervalSince1970, accuracy: 0.001)
    }

    func testSaveLoadActivities_Multiple() {
        // Given
        let activity1 = Activity(name: "Read Book", date: Date())
        let activity2 = Activity(name: "Write Code", descriptionText: "Work on project", date: Date().addingTimeInterval(1000))
        let activities = [activity1, activity2]

        // When
        PersistenceService.saveActivities(activities)
        let loadedActivities = PersistenceService.loadActivities()

        // Then
        XCTAssertEqual(loadedActivities.count, 2)
        XCTAssertEqual(loadedActivities[0].name, activity1.name)
        XCTAssertEqual(loadedActivities[1].name, activity2.name)
    }

    func testLoadActivities_NoData() {
        // When
        let loadedActivities = PersistenceService.loadActivities()

        // Then
        XCTAssertTrue(loadedActivities.isEmpty, "Should return an empty array when no data is saved.")
    }

    // MARK: - BookedActivity Tests

    func testSaveLoadBookedActivities_Empty() {
        // Given
        let bookedActivities: [BookedActivity] = []

        // When
        PersistenceService.saveBookedActivities(bookedActivities)
        let loadedBookedActivities = PersistenceService.loadBookedActivities()

        // Then
        XCTAssertTrue(loadedBookedActivities.isEmpty, "Loaded booked activities should be empty.")
    }

    func testSaveLoadBookedActivities_Single() {
        // Given
        let bookedActivity = BookedActivity(activityName: "Doctor Appointment", date: Date(), notes: "Annual checkup")
        let bookedActivities = [bookedActivity]

        // When
        PersistenceService.saveBookedActivities(bookedActivities)
        let loadedBookedActivities = PersistenceService.loadBookedActivities()

        // Then
        XCTAssertEqual(loadedBookedActivities.count, 1)
        XCTAssertEqual(loadedBookedActivities.first?.activityName, bookedActivity.activityName)
        XCTAssertEqual(loadedBookedActivities.first?.notes, bookedActivity.notes)
        XCTAssertEqual(loadedBookedActivities.first?.date.timeIntervalSince1970, bookedActivity.date.timeIntervalSince1970, accuracy: 0.001)
    }

    func testSaveLoadBookedActivities_Multiple() {
        // Given
        let booked1 = BookedActivity(activityName: "Lunch with Team", date: Date())
        let booked2 = BookedActivity(activityName: "Client Call", date: Date().addingTimeInterval(2000), notes: "Discuss new proposal")
        let bookedActivities = [booked1, booked2]

        // When
        PersistenceService.saveBookedActivities(bookedActivities)
        let loadedBookedActivities = PersistenceService.loadBookedActivities()

        // Then
        XCTAssertEqual(loadedBookedActivities.count, 2)
        XCTAssertEqual(loadedBookedActivities[0].activityName, booked1.activityName)
        XCTAssertEqual(loadedBookedActivities[1].activityName, booked2.activityName)
    }

    func testLoadBookedActivities_NoData() {
        // When
        let loadedBookedActivities = PersistenceService.loadBookedActivities()

        // Then
        XCTAssertTrue(loadedBookedActivities.isEmpty, "Should return an empty array when no booked data is saved.")
    }
}
