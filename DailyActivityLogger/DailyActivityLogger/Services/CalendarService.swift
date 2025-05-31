import Foundation
import EventKit

class CalendarService {

    private static let eventStore = EKEventStore()

    // MARK: - Permission Management
    static func requestCalendarAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }

    static func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }

    // MARK: - Event Management
    static func addEventToCalendar(bookedActivity: BookedActivity, completion: @escaping (Bool, Error?) -> Void) {
        let authStatus = getAuthorizationStatus()

        guard authStatus == .authorized else {
            // If not authorized, complete with false.
            // The request for permission should ideally be handled before calling this.
            let error = NSError(domain: "CalendarServiceError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Calendar access not authorized."])
            completion(false, error)
            return
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = bookedActivity.activityName
        event.startDate = bookedActivity.date
        event.endDate = bookedActivity.date.addingTimeInterval(3600) // Default to 1 hour duration
        event.notes = bookedActivity.notes

        // Attempt to set the calendar; defaults to defaultCalendarForNewEvents if specific calendar isn't found or set
        event.calendar = eventStore.defaultCalendarForNewEvents

        if event.calendar == nil {
             print("Default calendar for new events is nil. Ensure a calendar is selected or available on the device.")
             let error = NSError(domain: "CalendarServiceError", code: 500, userInfo: [NSLocalizedDescriptionKey: "No default calendar found."])
             completion(false, error)
             return
        }

        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            DispatchQueue.main.async {
                completion(true, nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(false, error)
            }
        }
    }
}
