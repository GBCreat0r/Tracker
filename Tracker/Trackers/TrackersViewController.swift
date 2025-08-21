//
//  TrackersViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit
import AppMetricaCore

final class TrackersViewController: UIViewController, TrackerCreateViewControllerDelegate {
    private let trackerStore = TrackerStore(context: CoreDataManager.shared.context)
    private let categoryStore = TrackerCategoryStore(context: CoreDataManager.shared.context)
    private let recordStore = TrackerRecordStore(context: CoreDataManager.shared.context)
    
    private var tittleLabel = UILabel()
    private let searchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = NSLocalizedString("search_placeholder", comment: "Плейсхолдер поиска")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private let filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters", comment: "Фильтры"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.4470588235, blue: 0.9058823529, alpha: 1)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var currentFilter: TrackerFilter = .all
    
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
        view.backgroundColor = Colors.background
        collectionView.backgroundColor = Colors.background
        collectionView.delegate = self
        collectionView.dataSource = self
        addAllUI()
        loadData()
        checkOnboardingStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.reportMainScreenOpen()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            AnalyticsService.shared.reportMainScreenClose()
        }
    }
    
    private func checkOnboardingStatus() {
        let onboardingCompleted = UserDefaults.standard.bool(forKey: TrackerOnboarding.onboardingKey)
        if !onboardingCompleted {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        let onboardingVC = TrackerOnboarding(transitionStyle: .scroll, navigationOrientation: .horizontal)
        onboardingVC.modalPresentationStyle = .fullScreen
        present(onboardingVC, animated: true)
    }
    
    private func loadData() {
        do {
            categories = try categoryStore.fetchCategories()
            completedTrackers = try recordStore.fetchRecords()
            filterTrackers(for: currentDate)
        } catch {
            print("Ошибка загрузки данных: \(error.localizedDescription)")
            AnalyticsService.shared.report(event: "error", screen: "Main", item: "load_data") 
        }
    }
    
    private func addFiltersButton() {
        view.addSubview(filtersButton)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84, right: 0)
        
        updateFiltersButtonVisibility()
    }
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker: tracker, categoryTitle: categoryTitle)
            AnalyticsService.shared.report(event: "tracker_created", screen: "Main")
            loadData()
        } catch {
            print("Ошибка сохранения трекера: \(error.localizedDescription)")
            AnalyticsService.shared.report(event: "error", screen: "Main", item: "create_tracker")
        }
    }
    
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.updateTracker(tracker, categoryTitle: categoryTitle)
            AnalyticsService.shared.report(event: "tracker_updated", screen: "Main")
            loadData()
        } catch {
            print("Ошибка обновления трекера: \(error.localizedDescription)")
            AnalyticsService.shared.report(event: "error", screen: "Main", item: "update_tracker")
        }
    }
    
    private func addAllUI() {
        addNewTrackerButton()
        addDatePickerToNavBar()
        addSearchBarAndLabel()
        addCollectionView()
        addFiltersButton()
        setupPlaceholder()
    }
    
    private func addCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12)
        ])
    }
    
    private func addSearchBarAndLabel() {
        
        tittleLabel.text = NSLocalizedString("trackers_title", comment: "Заголовок экрана трекеров")
        tittleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        tittleLabel.textColor = Colors.textPrimary
        tittleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tittleLabel)
        

        searchTextField.placeholder = NSLocalizedString("search_placeholder", comment: "Плейсхолдер поиска")
        searchTextField.backgroundColor = Colors.searchFieldBackground
        searchTextField.textColor = Colors.textPrimary
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("search_placeholder", comment: "Плейсхолдер поиска"),
            attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholder]
        )
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(searchBarTextDidChange), for: .editingChanged)
        view.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            tittleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tittleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.topAnchor.constraint(equalTo: tittleLabel.bottomAnchor, constant: 7),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func addNewTrackerButton () {
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(newTrackerButtonTapped))
        plusButton.tintColor = Colors.textPrimary
        navigationItem.leftBarButtonItem = plusButton
    }
    
    private func addDatePickerToNavBar() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.calendar.firstWeekday = 2
        datePicker.locale = Locale.current
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupPlaceholder() {
        
        placeholderImage.image = UIImage(resource: .placeholderTableView)
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderLabel.text = NSLocalizedString("empty_state_message", comment: "Сообщение при пустом списке")
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = Colors.textPrimary
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
        
        if isEmpty {
            if let searchText = searchTextField.text, !searchText.isEmpty {
                placeholderLabel.text = NSLocalizedString("nothing_found", comment: "Ничего не найдено")
                placeholderImage.image = UIImage(resource: .searchAndFilterPlaceholder)
            } else if currentFilter != .all {
                placeholderLabel.text = NSLocalizedString("nothing_found", comment: "Ничего не найдено")
                placeholderImage.image = UIImage(resource: .searchAndFilterPlaceholder)
            } else {
                placeholderLabel.text = NSLocalizedString("empty_state_message", comment: "Сообщение при пустом списке")
                placeholderImage.image = UIImage(resource: .placeholderTableView)
            }
        }
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
    
    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {
        let tracker = categoriesInDate[indexPath.section].trackers[indexPath.row]
        
        let editAction = UIAction(
            title: NSLocalizedString("edit", comment: "Редактировать")
        ) { [weak self] _ in
            AnalyticsService.shared.reportEditTap()
            self?.editTracker(tracker, at: indexPath)
        }
        
        let deleteAction = UIAction(
            title: NSLocalizedString("delete", comment: "Удалить"),
            attributes: .destructive
        ) { [weak self] _ in
            AnalyticsService.shared.reportDeleteTap()
            self?.confirmDeleteTracker(tracker, at: indexPath)
        }
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    private func editTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let categoryTitle = categoriesInDate[indexPath.section].title
        
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.setMode(.edit(tracker: tracker, categoryTitle: categoryTitle))
        createTrackerVC.setExistingCategories(categories.map { $0.title })
        createTrackerVC.delegate = self
        present(UINavigationController(rootViewController: createTrackerVC), animated: true)
    }
    
    private func confirmDeleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: NSLocalizedString("delete_tracker_title", comment: "Удаление трекера"),
            message: NSLocalizedString("delete_tracker_message", comment: "Уверены, что хотите удалить этот трекер?"),
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete", comment: "Удалить"),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker, at: indexPath)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: "Отмена"),
            style: .cancel
        ) { _ in
            AnalyticsService.shared.report(event: "click", screen: "Main", item: "delete_cancel")
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        do {
            try trackerStore.deleteTracker(tracker.trackerId)
            loadData()
        } catch {
            print("Ошибка удаления трекера: \(error.localizedDescription)")
        }
    }
    
    @objc private func filtersButtonTapped() {
        AnalyticsService.shared.reportFilterTap()
        let filtersVC = FiltersViewController(selectedFilter: currentFilter)
        filtersVC.delegate = self
        let navController = UINavigationController(rootViewController: filtersVC)
        present(navController, animated: true)
    }
    
    @objc func searchBarTextDidChange(_ searchField: UISearchTextField) {
        guard let searchText = searchField.text?.lowercased(), !searchText.isEmpty else {
            filterTrackers(for: currentDate)
            AnalyticsService.shared.report(event: "search", screen: "Main", item: "clear")
            return
        }
        
        AnalyticsService.shared.report(event: "search", screen: "Main", item: "query")
        
        let filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.title.lowercased().contains(searchText)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }
        
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let day = Weekday(rawValue: weekday) ?? .monday
        
        categoriesInDate = filteredCategories.compactMap { category in
            let trackersForDay = category.trackers.filter { $0.day.contains(day) }
            return trackersForDay.isEmpty ? nil : TrackerCategory(
                title: category.title,
                trackers: trackersForDay
            )
        }
        
        collectionView.reloadData()
        updateFiltersButtonVisibility()
        updatePlaceholderVisibility()
    }
    
    
    @objc func completedTracker(_ sender: UIButton) {
        AnalyticsService.shared.reportTrackTap()
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
        AnalyticsService.shared.report(event: "date_change", screen: "Main")
        
        if let searchText = searchTextField.text, !searchText.isEmpty {
            searchBarTextDidChange(searchTextField)
        } else {
            filterTrackers(for: currentDate)
        }
        updateFiltersButtonVisibility()
        updatePlaceholderVisibility()
    }
    
    @objc private func newTrackerButtonTapped () {
        AnalyticsService.shared.reportAddTrackTap()
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: 188, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            return self?.createContextMenu(for: indexPath) ?? UIMenu()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AnalyticsService.shared.reportTrackTap()
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        applyFilter(filter)
    }
    
    private func updateFiltersButtonVisibility() {
        let shouldHide = (currentFilter == .all) && categories.isEmpty
        filtersButton.isHidden = shouldHide
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        AnalyticsService.shared.report(event: "filter_apply", screen: "Main", item: filter.rawValue)
        
        if filter == .today {
            let datePicker = navigationItem.rightBarButtonItem?.customView as? UIDatePicker
            datePicker?.setDate(Date(), animated: true)
            currentDate = Date()
        }
        
        filterTrackers(for: currentDate)
    }
    
    private func filterTrackers(for date: Date) {
        let weekday = Calendar.current.component(.weekday, from: date)
        let day = Weekday(rawValue: weekday) ?? .monday
        
        var filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { $0.day.contains(day) }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        switch currentFilter {
        case .all, .today:
            break
            
        case .completed:
            filteredCategories = filteredCategories.compactMap { category in
                let completedTrackers = category.trackers.filter { tracker in
                    isTrackerCompleted(tracker.trackerId, date: date)
                }
                return completedTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: completedTrackers)
            }
            
        case .uncompleted:
            filteredCategories = filteredCategories.compactMap { category in
                let uncompletedTrackers = category.trackers.filter { tracker in
                    !isTrackerCompleted(tracker.trackerId, date: date)
                }
                return uncompletedTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: uncompletedTrackers)
            }
        }
        
        categoriesInDate = filteredCategories
        collectionView.reloadData()
        updateFiltersButtonVisibility()
        updatePlaceholderVisibility()
    }
}
