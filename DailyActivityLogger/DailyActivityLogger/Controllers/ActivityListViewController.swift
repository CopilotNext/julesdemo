import UIKit

class ActivityListViewController: UIViewController {

    // MARK: - Properties
    private var activities: [Activity] = []

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ActivityCell")
        return table
    }()

    // Formatter for the date
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Activity Log"
        view.backgroundColor = .white
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadActivities()
    }

    // MARK: - Setup
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Data Handling
    private func loadActivities() {
        activities = PersistenceService.loadActivities().sorted(by: { $0.date > $1.date }) // Show newest first
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ActivityListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
        let activity = activities[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = activity.name
        content.secondaryText = dateFormatter.string(from: activity.date)
        cell.contentConfiguration = content

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ActivityListViewController: UITableViewDelegate {
    // Optional: Add any delegate methods if needed, e.g., didSelectRowAt
}
