//
//  ScheduleSelectionViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 05.07.2025.
//

import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectDays(_ days: [Weekday])
}

final class ScheduleSelectionViewController: UIViewController {
    
    weak var delegate: ScheduleSelectionDelegate?
    var selectedDays: [Weekday] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        table.layer.cornerRadius = 16
        table.separatorStyle = .none
        table.isScrollEnabled = false
        return table
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(Weekday.allCases.count * 75)),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupActions() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didSelectDays(selectedDays)
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ScheduleSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let weekday = Weekday.allCases[indexPath.row]
        
        cell.configure(
            day: weekday.stringValue,
            isSelected: selectedDays.contains(weekday)
        )
        
        cell.switchValueChanged = { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                if !self.selectedDays.contains(weekday) {
                    self.selectedDays.append(weekday)
                }
            } else {
                self.selectedDays.removeAll { $0 == weekday }
            }
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        
        if indexPath.row < Weekday.allCases.count - 1 {
            cell.addSeparator()
        }
        
        return cell
    }
}

extension ScheduleSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let weekday = Weekday.allCases[indexPath.row]
        
        if let index = selectedDays.firstIndex(of: weekday) {
            selectedDays.remove(at: index)
        } else {
            selectedDays.append(weekday)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

final class ScheduleCell: UITableViewCell {
    var switchValueChanged: ((Bool) -> Void)?
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .blue
        return switchControl
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.isHidden = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(switchControl)
        contentView.addSubview(separatorView)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        switchValueChanged?(sender.isOn)
    }
    
    func configure(day: String, isSelected: Bool) {
        dayLabel.text = day
        switchControl.isOn = isSelected
    }
    
    func addSeparator() {
        separatorView.isHidden = false
    }
}
