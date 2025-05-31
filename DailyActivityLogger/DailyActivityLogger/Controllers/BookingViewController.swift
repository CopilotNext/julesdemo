import UIKit
import FSCalendar // Assuming pod install would make this available

class BookingViewController: UIViewController {

    // MARK: - Properties
    private var selectedDate: Date?
    private var bookedActivities: [BookedActivity] = []

    // MARK: - UI Elements
    private lazy var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scope = .month
        // Customize appearance as needed
        calendar.appearance.headerTitleColor = .systemBlue
        calendar.appearance.weekdayTextColor = .systemBlue
        calendar.appearance.todayColor = .systemOrange
        calendar.appearance.selectionColor = .systemBlue
        return calendar
    }()

    private lazy var addToCalendarSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.isOn = true // Default to on
        return uiSwitch
    }()

    private lazy var addToCalendarLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add to device calendar:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private lazy var calendarSwitchStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addToCalendarLabel, addToCalendarSwitch])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var activityNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Activity Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var notesTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        // Placeholder text
        textView.text = "Optional notes..."
        textView.textColor = UIColor.lightGray
        textView.delegate = self // For placeholder behavior
        return textView
    }()

    private lazy var bookActivityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Book Activity", for: .normal)
        button.addTarget(self, action: #selector(bookActivityTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calendar, activityNameTextField, notesTextView, calendarSwitchStackView, bookActivityButton])
        stackView.axis = .vertical
        stackView.spacing = 12 // Adjusted spacing
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()


    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Book Activity"
        view.backgroundColor = .systemGroupedBackground // Changed background for better contrast

        setupUI()
        loadBookedActivities() // Load existing bookings
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),

            calendar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4), // Calendar takes up 40% of view height
            activityNameTextField.heightAnchor.constraint(equalToConstant: 44),
            notesTextView.heightAnchor.constraint(equalToConstant: 100),
            bookActivityButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    @objc private func bookActivityTapped() {
        guard let activityName = activityNameTextField.text, !activityName.isEmpty else {
            showAlert(title: "Missing Name", message: "Please enter a name for the activity.")
            return
        }

        guard let date = selectedDate else {
            showAlert(title: "No Date Selected", message: "Please select a date from the calendar.")
            return
        }

        let notes = (notesTextView.text == "Optional notes..." || notesTextView.text.isEmpty) ? nil : notesTextView.text

        let newBooking = BookedActivity(activityName: activityName, date: date, notes: notes)

        bookedActivities.append(newBooking)
        PersistenceService.saveBookedActivities(bookedActivities)

        // Calendar Integration
        if addToCalendarSwitch.isOn {
            handleCalendarIntegration(for: newBooking)
        } else {
            showAlert(title: "Booked!", message: "\(activityName) booked for \(date.formatted(date: .long, time: .never)). Not added to device calendar.")
            clearInputFieldsAfterSave()
        }
        calendar.reloadData() // To update event markers
    }

    private func handleCalendarIntegration(for bookedActivity: BookedActivity) {
        CalendarService.requestCalendarAccess { [weak self] (granted, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error requesting calendar access: \(error.localizedDescription)")
                self.showAlert(title: "Calendar Error", message: "Could not request calendar access: \(error.localizedDescription)")
                self.clearInputFieldsAfterSave() // Clear fields even if calendar access fails initially
                return
            }

            if granted {
                CalendarService.addEventToCalendar(bookedActivity: bookedActivity) { (success, eventError) in
                    if success {
                        self.showAlert(title: "Booked & Added to Calendar!", message: "\(bookedActivity.activityName) booked and added to your device calendar.")
                    } else {
                        self.showAlert(title: "Booked (Calendar Error)", message: "\(bookedActivity.activityName) booked, but failed to add to calendar: \(eventError?.localizedDescription ?? "Unknown error")")
                    }
                    self.clearInputFieldsAfterSave()
                }
            } else {
                self.showAlert(title: "Booked (Calendar Access Denied)", message: "\(bookedActivity.activityName) booked. Calendar access was denied. You can grant access in Settings.")
                self.clearInputFieldsAfterSave()
            }
        }
    }

    private func clearInputFieldsAfterSave() { // Renamed to avoid confusion
        activityNameTextField.text = ""
        notesTextView.text = "Optional notes..."
        notesTextView.textColor = UIColor.lightGray
        selectedDate = nil // Reset selected date
        if let currentSelectedDate = calendar.selectedDate { // Deselect date in calendar
            calendar.deselect(currentSelectedDate)
        }
        // addToCalendarSwitch.setOn(true, animated: false) // Optionally reset switch
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Data Handling
    private func loadBookedActivities() {
        bookedActivities = PersistenceService.loadBookedActivities() // This function needs to be created
        calendar.reloadData() // To show event markers
    }
}

// MARK: - FSCalendarDataSource, FSCalendarDelegate
extension BookingViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        print("Selected date: \(date.formatted(date: .long, time: .never))")
        // Optionally, you could filter activities for this day or update UI
    }

    // Example: Add event dots for dates that have booked activities
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return bookedActivities.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }.count
    }
}

// MARK: - UITextViewDelegate for placeholder
extension BookingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label // Use adaptive color
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Optional notes..."
            textView.textColor = UIColor.lightGray
        }
    }
}
