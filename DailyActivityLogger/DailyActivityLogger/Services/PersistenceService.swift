import Foundation

class PersistenceService {

    private static let activitiesKey = "userActivities"

    static func saveActivities(_ activities: [Activity]) {
        do {
            let encoder = JSONEncoder()
            let encodedActivities = try encoder.encode(activities)
            UserDefaults.standard.set(encodedActivities, forKey: activitiesKey)
        } catch {
            print("Failed to encode activities: \(error.localizedDescription)")
        }
    }

    static func loadActivities() -> [Activity] {
        guard let savedActivitiesData = UserDefaults.standard.data(forKey: activitiesKey) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            let loadedActivities = try decoder.decode([Activity].self, from: savedActivitiesData)
            return loadedActivities
        } catch {
            print("Failed to decode activities: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Booked Activities Persistence
    private static let bookedActivitiesKey = "userBookedActivities"

    static func saveBookedActivities(_ activities: [BookedActivity]) {
        do {
            let encoder = JSONEncoder()
            let encodedBookedActivities = try encoder.encode(activities)
            UserDefaults.standard.set(encodedBookedActivities, forKey: bookedActivitiesKey)
        } catch {
            print("Failed to encode booked activities: \(error.localizedDescription)")
        }
    }

    static func loadBookedActivities() -> [BookedActivity] {
        guard let savedBookedActivitiesData = UserDefaults.standard.data(forKey: bookedActivitiesKey) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            let loadedBookedActivities = try decoder.decode([BookedActivity].self, from: savedBookedActivitiesData)
            return loadedBookedActivities
        } catch {
            print("Failed to decode booked activities: \(error.localizedDescription)")
            return []
        }
    }
}
