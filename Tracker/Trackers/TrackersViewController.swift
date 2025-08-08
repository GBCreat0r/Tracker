//
//  TrackersViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit

final class TrackersViewController: UIViewController, TrackerCreateViewControllerDelegate {
    private let trackerStore = TrackerStore(context: CoreDataManager.shared.context)
    private let categoryStore = TrackerCategoryStore(context: CoreDataManager.shared.context)
    private let recordStore = TrackerRecordStore(context: CoreDataManager.shared.context)
    
    private var tittleLabel = UILabel()
    private var searchBar = UISearchBar()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self,
                                forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "Header")
        return collectionView
    }()
    private let placeholderLabel = UILabel()
    private let placeholderImage = UIImageView()
    
    private var categories: [TrackerCategory] = []
    private var categoriesInDate: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        addAllUI()
        loadData()
        
        if categories.isEmpty {
            setupPlaceholder()
        }
    }
    
    private func loadData() {
        do {
            self.categories = try categoryStore.fetchCategories()
            self.completedTrackers = try recordStore.fetchRecords()
            filterTrackers(for: currentDate)
        } catch {
            print("Ошибка загрузки данных: \(error.localizedDescription)")
        }
    }
    
    private func filterTrackers(for date: Date) {
        let weekday = Calendar.current.component(.weekday, from: date)
        let day = Weekday(rawValue: weekday) ?? .monday
        
        categoriesInDate = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { $0.day.contains(day) }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker: tracker, categoryTitle: categoryTitle)
            loadData()
        } catch {
            print("Ошибка сохранения трекера: \(error.localizedDescription)")
        }
    }
    
    private func addAllUI() {
        addNewTrackerButton()
        addDatePickerToNavBar()
        addSearchBarAndLabel()
        addCollectionView()
    }
    
    private func addCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12)
        ])
    }
    
    private func addSearchBarAndLabel() {
        
        tittleLabel.text = "Трекеры"
        tittleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        tittleLabel.textColor = .black
        tittleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tittleLabel)
        
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            tittleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tittleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: tittleLabel.bottomAnchor, constant: 7),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func addNewTrackerButton () {
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(newTrackerButtonTapped))
        plusButton.tintColor = .black
        navigationItem.leftBarButtonItem = plusButton
    }
    
    private func addDatePickerToNavBar() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.calendar.firstWeekday = 2
        datePicker.locale = Locale(identifier: "ru_RU")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    func setupPlaceholder() {
        
        placeholderImage.image = UIImage(resource: .placeholderTableView)
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = .gray
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
        ])
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = categoriesInDate.isEmpty
        placeholderLabel.isHidden = !isEmpty
        placeholderImage.isHidden = !isEmpty
    }
    
    private func rightDayText(counter: Int) -> String {
        String(format: NSLocalizedString("day_count", comment: ""), counter)
    }
    
    private func isTrackerCompleted(_ trackerId: UUID, date: Date) -> Bool {
        completedTrackers.contains { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    private func addAndDeleteTrackerRecord(_ trackerId: UUID, date: Date) {
        do {
            if isTrackerCompleted(trackerId, date: date) {
                try recordStore.deleteRecord(trackerID: trackerId, date: date)
            } else {
                try recordStore.addRecord(trackerID: trackerId, date: date)
            }
            completedTrackers = try recordStore.fetchRecords()
        } catch {
            print("Ошибка изменения записи: \(error.localizedDescription)")
        }
    }
    
    private func completeDaysCounter(tracerId: UUID) -> Int {
        do {
            return try recordStore.countRecords(for: tracerId)
        } catch {
            print("Failed to count records: \(error)")
            return 0
        }
    }
    
    @objc func completedTracker(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? TrackerCollectionViewCell,
              let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let tracker = categoriesInDate[indexPath.section].trackers[indexPath.row]
        let datePicker = navigationItem.rightBarButtonItem?.customView as? UIDatePicker
        let selectedDate = datePicker?.date ?? Date()
        
        if selectedDate > Date() { return }
        
        addAndDeleteTrackerRecord(tracker.trackerId, date: selectedDate)
        
        let isCompleted = isTrackerCompleted(tracker.trackerId, date: selectedDate)
        sender.setImage(UIImage(systemName: isCompleted ? "checkmark" : "plus"), for: .normal)
        
        let counter = completeDaysCounter(tracerId: tracker.trackerId)
        let counterText = rightDayText(counter: counter)
        cell.counterLabel.text = counterText
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filterTrackers(for: currentDate)
    }
    
    @objc private func newTrackerButtonTapped () {
        let createTrackerVS = CreateTrackerViewController()
        let categoriesTitle = categories.map {$0.title}
        createTrackerVS.setExistingCategories(categoriesTitle)
        createTrackerVS.delegate = self
        present(UINavigationController(rootViewController: createTrackerVS), animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categoriesInDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        categoriesInDate[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCollectionViewCell
        let tracker = categoriesInDate[indexPath.section].trackers[indexPath.row]
        
        cell.textLabel.text = tracker.title
        cell.backgroundImage.backgroundColor = Colors.colors[tracker.colorIndex]
        cell.emojiLabel.text = tracker.emoji
        
        let datePicker = navigationItem.rightBarButtonItem?.customView as? UIDatePicker
        let selectedDate = datePicker?.date ?? Date()
        let isCompleted = isTrackerCompleted(tracker.trackerId, date: selectedDate)
        
        cell.checkButton.setImage(UIImage(systemName: isCompleted ? "checkmark" : "plus"), for: .normal)
        cell.checkButton.backgroundColor = Colors.colors[tracker.colorIndex]
        
        let counter = completeDaysCounter(tracerId: tracker.trackerId)
        let counterText = rightDayText(counter: counter)
        cell.counterLabel.text = counterText
        
        cell.checkButton.addTarget(self, action: #selector (completedTracker(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "Header",
            for: indexPath) as! HeaderSupplementaryView
        header.titleLabel.text = categoriesInDate[indexPath.section].title
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 16 * 2 - 9
        let cellWidth = width / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    //TODO: посмотри методы отступа сверху и снизу и не забудь что изменил верхний кнст КВшки
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: 188, height: 20)
    }
}


//    private func setupMockCategories() {
//        let healthTrackers = [
//            Tracker(trackerId: UUID(), title: "Пить воду", emoji: "💧", colorIndex: 3, day: Weekday.allCases, counterDays: 0),
//            Tracker(trackerId: UUID(), title: "Спать 8 часов", emoji: "😴", colorIndex: 2, day: [.monday, .tuesday, .wednesday, .thursday, .sunday], counterDays: 4)
//        ]
//
//        let workTrackers = [
//            Tracker(trackerId: UUID(), title: "Планерка", emoji: "📋", colorIndex: 7, day: [.monday, .wednesday, .friday], counterDays: 1)
//        ]
//
//        categories = [
//            TrackerCategory(title: "Здоровье", trackers: healthTrackers),
//            TrackerCategory(title: "Работа", trackers: workTrackers)
//        ]
//        categoriesInDate = categories
//    }
