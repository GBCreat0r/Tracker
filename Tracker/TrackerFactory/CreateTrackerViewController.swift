//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by semrumyantsev on 04.07.2025.
//

import UIKit
import CoreData

protocol TrackerCreateViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
}

final class CreateTrackerViewController: UIViewController {
    weak var delegate: TrackerCreateViewControllerDelegate?
    
//    let context: NSManagedObjectContext
//    
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9098039216, blue: 0.9215686275, alpha: 0.3)
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let categoryScheduleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9098039216, blue: 0.9215686275, alpha: 0.3)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoryButton = createSelectionButton(title: "Категория")
    private let scheduleButton = createSelectionButton(title: "Расписание")
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private let emojiTitle: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorTitle: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.9607843137, green: 0.4196078431, blue: 0.4235294118, alpha: 1), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.9607843137, green: 0.4196078431, blue: 0.4235294118, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.6823529412, green: 0.6862745098, blue: 0.7058823529, alpha: 1)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let colors: [UIColor] = [
        #colorLiteral(red: 0.9921568627, green: 0.2980392157, blue: 0.2862745098, alpha: 1),#colorLiteral(red: 1, green: 0.5333333333, blue: 0.1176470588, alpha: 1),#colorLiteral(red: 0, green: 0.4823529412, blue: 0.9803921569, alpha: 1),#colorLiteral(red: 0.431372549, green: 0.2666666667, blue: 0.9960784314, alpha: 1),#colorLiteral(red: 0.2, green: 0.8117647059, blue: 0.4117647059, alpha: 1),#colorLiteral(red: 0.9019607843, green: 0.4274509804, blue: 0.831372549, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.831372549, blue: 0.831372549, alpha: 1),#colorLiteral(red: 0.2039215686, green: 0.6549019608, blue: 0.9960784314, alpha: 1),#colorLiteral(red: 0.2745098039, green: 0.9019607843, blue: 0.6156862745, alpha: 1),#colorLiteral(red: 0.2078431373, green: 0.2039215686, blue: 0.4862745098, alpha: 1),#colorLiteral(red: 1, green: 0.4039215686, blue: 0.3019607843, alpha: 1),#colorLiteral(red: 1, green: 0.6, blue: 0.8, alpha: 1),#colorLiteral(red: 0.9647058824, green: 0.768627451, blue: 0.5450980392, alpha: 1),#colorLiteral(red: 0.4745098039, green: 0.5803921569, blue: 0.9607843137, alpha: 1),#colorLiteral(red: 0.5137254902, green: 0.1725490196, blue: 0.9450980392, alpha: 1),#colorLiteral(red: 0.6784313725, green: 0.337254902, blue: 0.8549019608, alpha: 1),#colorLiteral(red: 0.5529411765, green: 0.4470588235, blue: 0.9019607843, alpha: 1),#colorLiteral(red: 0.1843137255, green: 0.8156862745, blue: 0.3450980392, alpha: 1)
    ]
    
    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    
    private var oldColor: UIColor = .red
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategory: String?
    private var selectedDays: [Weekday] = []
    private var existingCategories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        setupUI()
        setupActions()
        
        textField.delegate = self
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
    }
    
    func setExistingCategories(_ categories: [String]) {
        existingCategories = categories
    }
        
    private static func createSelectionButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return button
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        contentView.addSubview(categoryScheduleContainer)
        contentView.addSubview(emojiTitle)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorTitle)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        
        categoryScheduleContainer.addSubview(categoryButton)
        categoryScheduleContainer.addSubview(separatorView)
        categoryScheduleContainer.addSubview(scheduleButton)
        
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: categoryScheduleContainer.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            scheduleButton.bottomAnchor.constraint(equalTo: categoryScheduleContainer.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            categoryScheduleContainer.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            categoryScheduleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryScheduleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryScheduleContainer.heightAnchor.constraint(equalToConstant: 151),
            
            emojiTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiTitle.topAnchor.constraint(equalTo: categoryScheduleContainer.bottomAnchor, constant: 32),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitle.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 156),
            
            colorTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorTitle.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 24),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorTitle.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 156),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 40),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func updateCreateButtonState() {
        let isEnabled = !(textField.text?.isEmpty ?? true) &&
        selectedCategory != nil &&
        !selectedDays.isEmpty &&
        selectedEmoji != nil &&
        selectedColor != nil
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1) : #colorLiteral(red: 0.6823529412, green: 0.6862745098, blue: 0.7058823529, alpha: 1)
    }
    
    private func updateCategoryButton(title: String?) {
        if let title = title {
            let attributedTitle = NSMutableAttributedString(
                string: "Категория\n",
                attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
            )
            attributedTitle.append(NSAttributedString(
                string: title,
                attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular), .foregroundColor: UIColor.gray]
            ))
            categoryButton.setAttributedTitle(attributedTitle, for: .normal)
            categoryButton.titleLabel?.numberOfLines = 2
        } else {
            categoryButton.setTitle("Категория", for: .normal)
            categoryButton.titleLabel?.numberOfLines = 1
        }
    }
    
    private func updateScheduleButton() {
        if !selectedDays.isEmpty {
            let daysString = selectedDays.map { $0.stringValue }.joined(separator: ", ")
            let attributedTitle = NSMutableAttributedString(
                string: "Расписание\n",
                attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
            )
            attributedTitle.append(NSAttributedString(
                string: daysString,
                attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular), .foregroundColor: UIColor.gray]
            ))
            scheduleButton.setAttributedTitle(attributedTitle, for: .normal)
            scheduleButton.titleLabel?.numberOfLines = 2
        } else {
            scheduleButton.setTitle("Расписание", for: .normal)
            scheduleButton.titleLabel?.numberOfLines = 1
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let title = textField.text, !title.isEmpty,
              let emoji = selectedEmoji,
              let colorIndex = colors.firstIndex(where: { $0 == selectedColor}),
              let category = selectedCategory else { return }
        
        let newTracker = Tracker(
            trackerId: UUID(),
            title: title,
            emoji: emoji,
            colorIndex: colorIndex,
            //trackerType: selectedDays.count == Weekday.allCases.count ? .regular : .irregular,
            day: selectedDays,
            counterDays: 0
        )
        delegate?.didCreateTracker(newTracker, categoryTitle: category)
        dismiss(animated: true)
    }
    
    @objc private func categoryButtonTapped() {
        let vc = CategorySelectionViewController()
        vc.setCategories(existingCategories)
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func scheduleButtonTapped() {
        let vc = ScheduleSelectionViewController()
        vc.selectedDays = selectedDays
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
}

extension CreateTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
            cell.configure(with: emojis[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.configure(with: colors[indexPath.row])
            return cell
        }
    }
}

extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.row]
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell
            cell?.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9098039216, blue: 0.9215686275, alpha: 0.5)
            cell?.layer.cornerRadius = 16
        } else {
            selectedColor = colors[indexPath.row]
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCell
            cell?.layer.cornerRadius = 10.4
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = cell?.colorView.backgroundColor?.cgColor.copy(alpha: 0.5)
        }
        updateCreateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.row]
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell
            cell?.backgroundColor = .none
        } else {
            selectedColor = colors[indexPath.row]
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCell
            cell?.layer.borderWidth = 0
        }
        updateCreateButtonState()
    }
}

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let cellsPerRow: CGFloat = 6
        let cellWidth: CGFloat = 52
        let spacing: CGFloat = 5
        
        let totalWidth = (cellWidth * cellsPerRow) + (spacing * (cellsPerRow - 1))
        let leftInset = (collectionView.frame.width - totalWidth) / 2
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: leftInset)
    }
}

extension CreateTrackerViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        updateCategoryButton(title: category)
        updateCreateButtonState()
    }
}

extension CreateTrackerViewController: ScheduleSelectionDelegate {
    func didSelectDays(_ days: [Weekday]) {
        selectedDays = days
        updateScheduleButton()
        updateCreateButtonState()
    }
}
