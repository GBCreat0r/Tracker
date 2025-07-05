//
//  TrackersViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit

final class TrackersViewController: UIViewController {
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
    
    let colors: [UIColor] = [
        .black, .blue, .brown,
        .cyan, .green, .orange,
        .red, .purple, .yellow
    ]
    private var categories: [TrackerCategory] = []
    private var categoriesInDate: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        addAllUI()
    }
    
    private func addAllUI() {
        addNewTrackerButton()
        addDatePickerToNavBar()
        addSearchBarAndLabel()
        addCollectionView()
        
        if categories.isEmpty {
            setupMockCategories()
        }
    }
    
    private func setupMockCategories() {
        let healthTrackers = [
            Tracker(trackerId: UUID(), title: "Пить воду", emoji: "💧", color: "blue",
                   trackerType: .regular, day: Weekday.allCases, counterDays: 0),
            Tracker(trackerId: UUID(), title: "Спать 8 часов", emoji: "😴", color: "green",
                   trackerType: .regular, day: Weekday.allCases, counterDays: 4)
        ]
        
        let workTrackers = [
            Tracker(trackerId: UUID(), title: "Планерка", emoji: "📋", color: "red",
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
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
      
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    @objc private func newTrackerButtonTapped () {
        
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
        cell.backgroundImage.backgroundColor = colors[Int.random(in: 0..<colors.count)]
        cell.emojiLabel.text = tracker.emoji
        
        var counterText = ""
        if tracker.counterDays == 1 {
            counterText = "\(tracker.counterDays) день"
        } else if tracker.counterDays <= 4 && tracker.counterDays != 0 {
            counterText = "\(tracker.counterDays) дня"
        } else {
            counterText = "\(tracker.counterDays) дней"
        }
        
        cell.counterLabel.text = counterText
        cell.checkButton.backgroundColor = cell.backgroundImage.backgroundColor
        
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
    
//    func setupPlaceholder() {
//        var placeholderLabel = UILabel()
//        var placeholderImage = UIImageView()
//        
//        placeholderImage.image = UIImage(resource: .placeholderTableView)
//        placeholderImage.contentMode = .scaleAspectFit
//        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
//        
//        placeholderLabel.text = "Что будем отслеживать?"
//        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        placeholderLabel.textColor = .gray
//        placeholderLabel.textAlignment = .center
//        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(placeholderImage)
//        view.addSubview(placeholderLabel)
//        
//        NSLayoutConstraint.activate([
//            placeholderImage.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
//            placeholderImage.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
//            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
//            placeholderLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
//        ])
//    }
