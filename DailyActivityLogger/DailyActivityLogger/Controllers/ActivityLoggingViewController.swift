import UIKit

class ActivityLoggingViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Activity Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.font = UIFont.systemFont(ofSize: 16) // Placeholder typical size
        textView.translatesAutoresizingMaskIntoConstraints = false
        // Placeholder text
        textView.text = "Enter activity description..."
        textView.textColor = UIColor.lightGray
        textView.delegate = self // For placeholder behavior
        return textView
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels // Or .inline, .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Activity", for: .normal)
        button.addTarget(self, action: #selector(saveActivityTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameTextField, descriptionTextView, datePicker, saveButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Log Activity" // Setting a title for the view controller
        setupNavigationBar()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupNavigationBar() {
        let viewLogsButton = UIBarButtonItem(title: "View Logs", style: .plain, target: self, action: #selector(viewLogsTapped))
        let bookActivityButton = UIBarButtonItem(title: "Book Activity", style: .plain, target: self, action: #selector(bookActivityTappedNav))
        navigationItem.rightBarButtonItems = [viewLogsButton, bookActivityButton]
    }

    private func setupUI() {
        view.addSubview(stackView)

        // Constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            // Give specific height constraints to text field and button for better layout within stack view
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120), // Give some decent height for description
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    @objc private func viewLogsTapped() {
        let listVC = ActivityListViewController()
        navigationController?.pushViewController(listVC, animated: true)
    }

    @objc private func bookActivityTappedNav() {
        let bookingVC = BookingViewController()
        navigationController?.pushViewController(bookingVC, animated: true)
    }

    @objc private func saveActivityTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Missing Name", message: "Please enter a name for the activity.")
            return
        }

        let description = (descriptionTextView.text == "Enter activity description..." || descriptionTextView.text.isEmpty) ? nil : descriptionTextView.text

        let newActivity = Activity(name: name, descriptionText: description, date: datePicker.date)

        var existingActivities = PersistenceService.loadActivities()
        existingActivities.append(newActivity)
        PersistenceService.saveActivities(existingActivities)

        clearInputFields()
        showAlert(title: "Saved!", message: "Your activity has been saved.")
    }

    private func clearInputFields() {
        nameTextField.text = ""
        descriptionTextView.text = "Enter activity description..."
        descriptionTextView.textColor = UIColor.lightGray
        datePicker.setDate(Date(), animated: false) // Reset to current date
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate for placeholder
extension ActivityLoggingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter activity description..."
            textView.textColor = UIColor.lightGray
        }
    }
}
