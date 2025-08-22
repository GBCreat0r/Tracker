//
//  FiltersViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 21.08.2025.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

enum TrackerFilter: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершённые"
    case uncompleted = "Незавершённые"
    
    var localizedTitle: String {
        switch self {
        case .all: return NSLocalizedString("all_trackers", comment: "Все трекеры")
        case .today: return NSLocalizedString("today_trackers", comment: "Трекеры на сегодня")
        case .completed: return NSLocalizedString("completed", comment: "Завершённые")
        case .uncompleted: return NSLocalizedString("uncompleted", comment: "Незавершённые")
        }
    }
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    private let selectedFilter: TrackerFilter
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = Colors.placeholder
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        return tableView
    }()
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.background
        title = NSLocalizedString("filters", comment: "Фильтры")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(TrackerFilter.allCases.count * 75))
        ])
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = TrackerFilter.allCases[indexPath.row]
        
        cell.textLabel?.text = filter.localizedTitle
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9098039216, blue: 0.9215686275, alpha: 0.3)
        cell.selectionStyle = .none
        
        if filter == selectedFilter && filter != .all && filter != .today {
            cell.accessoryType = .checkmark
            cell.tintColor = .blue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = TrackerFilter.allCases[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
}
