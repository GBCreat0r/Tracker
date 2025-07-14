//
//  TrackersViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit

final class TrackersViewController: UIViewController, TrackerCreateViewControllerDelegate {
    
    private var tittleLabel = UILabel()
    private var searchBar = UISearchBar()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        return collectionView
    }()
    private let placeholderLabel = UILabel()
    private let placeholderImage = UIImageView()
    
    private let colors: [UIColor] = [
        #colorLiteral(red: 0.9921568627, green: 0.2980392157, blue: 0.2862745098, alpha: 1),#colorLiteral(red: 1, green: 0.5333333333, blue: 0.1176470588, alpha: 1),#colorLiteral(red: 0, green: 0.4823529412, blue: 0.9803921569, alpha: 1),#colorLiteral(red: 0.431372549, green: 0.2666666667, blue: 0.9960784314, alpha: 1),#colorLiteral(red: 0.2, green: 0.8117647059, blue: 0.4117647059, alpha: 1),#colorLiteral(red: 0.9019607843, green: 0.4274509804, blue: 0.831372549, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.831372549, blue: 0.831372549, alpha: 1),#colorLiteral(red: 0.2039215686, green: 0.6549019608, blue: 0.9960784314, alpha: 1),#colorLiteral(red: 0.2745098039, green: 0.9019607843, blue: 0.6156862745, alpha: 1),#colorLiteral(red: 0.2078431373, green: 0.2039215686, blue: 0.4862745098, alpha: 1),#colorLiteral(red: 1, green: 0.4039215686, blue: 0.3019607843, alpha: 1),#colorLiteral(red: 1, green: 0.6, blue: 0.8, alpha: 1),#colorLiteral(red: 0.9647058824, green: 0.768627451, blue: 0.5450980392, alpha: 1),#colorLiteral(red: 0.4745098039, green: 0.5803921569, blue: 0.9607843137, alpha: 1),#colorLiteral(red: 0.5137254902, green: 0.1725490196, blue: 0.9450980392, alpha: 1),#colorLiteral(red: 0.6784313725, green: 0.337254902, blue: 0.8549019608, alpha: 1),#colorLiteral(red: 0.5529411765, green: 0.4470588235, blue: 0.9019607843, alpha: 1),#colorLiteral(red: 0.1843137255, green: 0.8156862745, blue: 0.3450980392, alpha: 1)
    ]
    
    private var categories: [TrackerCategory] = []
    private var categoriesInDate: [TrackerCategory] = []
    private var completedTracker: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        addAllUI()
        
        if categories.isEmpty {
            setupPlaceholder()
        }
    }
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let category = categories[index]
            var trackers = category.trackers
            trackers.append(tracker)
            categories[index] = TrackerCategory(title: category.title, trackers: trackers)
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        placeholderImage.removeFromSuperview()
        placeholderLabel.removeFromSuperview()
        categoriesInDate = categories
        collectionView.reloadData()
    }
    
    private func addAllUI() {
        addNewTrackerButton()
        addDatePickerToNavBar()
        addSearchBarAndLabel()
        addCollectionView()
        
        //Запуск МОК категорий
        if categories.isEmpty {
            setupMockCategories()
        }
    }
    
    private func setupMockCategories() {
        let healthTrackers = [
            Tracker(trackerId: UUID(), title: "Пить воду", emoji: "💧", colorIndex: 3,
                    trackerType: .regular, day: Weekday.allCases, counterDays: 0),
            Tracker(trackerId: UUID(), title: "Спать 8 часов", emoji: "😴", colorIndex: 2,
                    trackerType: .regular, day: [.monday, .tuesday, .wednesday, .thursday, .sunday], counterDays: 4)
        ]
        
        let workTrackers = [
            Tracker(trackerId: UUID(), title: "Планерка", emoji: "📋", colorIndex: 7,
                    trackerType: .regular, day: [.monday, .wednesday, .friday], counterDays: 1)
        ]
        
        categories = [
            TrackerCategory(title: "Здоровье", trackers: healthTrackers),
            TrackerCategory(title: "Работа", trackers: workTrackers)
        ]
        categoriesInDate = categories
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
    
    //TODO: верни его
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
    
    private func rightDayText(counter: Int) -> String {
        String(format: NSLocalizedString("day_count", comment: ""), counter)
    }
    
    private func isTrackerCompleted(_ trackerId: UUID, date: Date) -> Bool {
        completedTracker.contains { result in
            result.trackerId == trackerId && Calendar.current.isDate(result.date, inSameDayAs: date)}
    }
    
    private func addAndDeleteTrackerRecord(_ trackerId: UUID, date: Date) {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        if let index = completedTracker.firstIndex (where: { result in
            result.trackerId == trackerId && calendar.isDate(result.date, inSameDayAs: normalizedDate)
        }) {
            completedTracker.remove(at: index)
        } else {
            completedTracker.append(TrackerRecord(trackerId: trackerId, date: normalizedDate))
        }
    }
    
    private func completeDaysCounter(tracerId: UUID) -> Int {
        completedTracker.filter { $0.trackerId == tracerId }.count
    }
    
    //TODO: Надо разобраться с правильным отображением даты
    //    private func formattedDateString(from date: Date) -> String {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "dd MMMM yyyy"
    //        return dateFormatter.string(from: date)
    //    }
    //
    //    private func undateDateLabel() {
    //        let dateString = formattedDateString(from: Date())
    //        dateLabel.text = dateString
    //    }
    
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
        let selectedDate = sender.date
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: selectedDate)
        
        categoriesInDate = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let trackerWeekdays = tracker.day.map { $0.rawValue }
                return trackerWeekdays.contains(selectedWeekday)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        collectionView.reloadData()
        
        if !categoriesInDate.isEmpty {
            collectionView.scrollToItem(
                at: IndexPath(item: 0, section: 0),
                at: .top,
                animated: true
            )
        }
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
        cell.backgroundImage.backgroundColor = colors[tracker.colorIndex]
        cell.emojiLabel.text = tracker.emoji
        
        let datePicker = navigationItem.rightBarButtonItem?.customView as? UIDatePicker
        let selectedDate = datePicker?.date ?? Date()
        let isCompleted = isTrackerCompleted(tracker.trackerId, date: selectedDate)
        
        cell.checkButton.setImage(UIImage(systemName: isCompleted ? "checkmark" : "plus"), for: .normal)
        cell.checkButton.backgroundColor = colors[tracker.colorIndex]
        
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

