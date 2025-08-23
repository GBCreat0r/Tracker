//
//  StatisticViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//
import UIKit

final class StatisticViewController: UIViewController {
    private let trackerStore = TrackerStore(context: CoreDataManager.shared.context)
    private let recordStore = TrackerRecordStore(context: CoreDataManager.shared.context)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        loadStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    private func rebuildUI(hasData: Bool) {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        if hasData {
            setupStatisticsUI()
        } else {
            setupPlaceholderUI()
        }
    }
    
    private func setupStatisticsUI() {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("statistics_title", comment: "Статистика")
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let titles = [
            NSLocalizedString("best_period", comment: "Лучший период"),
            NSLocalizedString("perfect_days", comment: "Идеальные дни"),
            NSLocalizedString("completed_trackers", comment: "Трекеров завершено"),
            NSLocalizedString("average_value", comment: "Среднее значение")
        ]
        
        for title in titles {
            let cardView = createCardView(with: title)
            stackView.addArrangedSubview(cardView)
        }
        
        updateStackViewTopConstraint(for: stackView)
        
        DispatchQueue.main.async {
            self.addGradientBorders(to: stackView.arrangedSubviews)
        }
    }
    
    private func updateStackViewTopConstraint(for stackView: UIStackView) {
        let cardHeight: CGFloat = 90
        let spacing: CGFloat = 12
        let totalStackHeight = 4 * cardHeight + 3 * spacing
        let screenHeight = view.bounds.height
        let topInset = (screenHeight / 2) - (totalStackHeight / 2)
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset).isActive = true
    }
    
    private func setupPlaceholderUI() {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("statistics_title", comment: "Статистика")
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let placeholderImage = UIImageView()
        placeholderImage.image = UIImage(resource: .statisticsPlaceholder)
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImage)
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("statistics_empty_message", comment: "Анализировать пока нечего")
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = Colors.textPrimary
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func createCardView(with title: String) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = Colors.background
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        let countLabel = UILabel()
        countLabel.tag = 100
        countLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        countLabel.textColor = Colors.textPrimary
        countLabel.text = "0"
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = title
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = Colors.textPrimary
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(countLabel)
        cardView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        
        return cardView
    }
    
    private func addGradientBorders(to cardViews: [UIView]) {
        for cardView in cardViews {
            guard cardView.bounds.width > 0 else { continue }
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(
                x: -1,
                y: -1,
                width: cardView.bounds.width + 2,
                height: cardView.bounds.height + 2
            )
            
            gradientLayer.colors = [
                UIColor(red: 0.9921568627, green: 0.2980392157, blue: 0.2862745098, alpha: 1).cgColor,
                UIColor(red: 0.2745098039, green: 0.9019607843, blue: 0.6156862745, alpha: 1).cgColor,
                UIColor(red: 0, green: 0.4823529412, blue: 0.9803921569, alpha: 1).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.cornerRadius = 17
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.lineWidth = 1
            shapeLayer.path = UIBezierPath(
                roundedRect: CGRect(
                    x: 1,
                    y: 1,
                    width: cardView.bounds.width - 2,
                    height: cardView.bounds.height - 2
                ),
                cornerRadius: 16
            ).cgPath
            shapeLayer.fillColor = nil
            shapeLayer.strokeColor = UIColor.black.cgColor
            gradientLayer.mask = shapeLayer
            
            cardView.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    private func loadStatistics() {
        do {
            let records = try recordStore.fetchRecords()
            let trackers = try trackerStore.fetchTrackers()
            
            let hasData = !records.isEmpty
            rebuildUI(hasData: hasData)
            
            if hasData {
                updateCardValues(records: records, trackers: trackers)
            }
            
        } catch {
            print("Ошибка загрузки статистики: \(error.localizedDescription)")
            rebuildUI(hasData: false)
        }
    }
    
    private func updateCardValues(records: [TrackerRecord], trackers: [Tracker]) {
        guard let stackView = view.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }
        
        let bestPeriod = calculateBestPeriod(records: records)
        let perfectDays = calculatePerfectDays(records: records, trackers: trackers)
        let completedTrackers = records.count
        let averageValue = calculateAverageValue(records: records)
        
        let values = [bestPeriod, perfectDays, completedTrackers, averageValue]
        
        for (index, cardView) in stackView.arrangedSubviews.enumerated() {
            if index < values.count, let countLabel = cardView.viewWithTag(100) as? UILabel {
                countLabel.text = "\(values[index])"
            }
        }
    }
    
    private func calculateBestPeriod(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let dates = records.map { calendar.startOfDay(for: $0.date) }
        let uniqueDates = Array(Set(dates)).sorted()
        
        var bestStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for date in uniqueDates {
            if let previous = previousDate {
                let daysBetween = calendar.dateComponents([.day], from: previous, to: date).day ?? 0
                currentStreak = daysBetween == 1 ? currentStreak + 1 : 1
            } else {
                currentStreak = 1
            }
            
            bestStreak = max(bestStreak, currentStreak)
            previousDate = date
        }
        return bestStreak
    }
    
    private func calculatePerfectDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var perfectDays = 0
        
        let recordsByDay = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }
        
        for (date, dayRecords) in recordsByDay {
            let weekday = calendar.component(.weekday, from: date)
            
            let scheduledTrackers = trackers.filter { tracker in
                tracker.day.contains { $0.rawValue == weekday }
            }
            
            let completedIDs = Set(dayRecords.map { $0.trackerId })
            let scheduledIDs = Set(scheduledTrackers.map { $0.trackerId })
            
            if scheduledIDs.isSubset(of: completedIDs) && !scheduledIDs.isEmpty {
                perfectDays += 1
            }
        }
        return perfectDays
    }
    
    private func calculateAverageValue(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.date) }).count
        
        let averageValue = Int(round(Double(records.count) / Double(uniqueDays)))
        return averageValue
    }
}
