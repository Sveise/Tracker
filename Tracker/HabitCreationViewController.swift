//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 02.09.2025.
//

import UIKit

// MARK: - Protocol
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}

protocol HabitCreationViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String?)
    func didSelectCategory(_ category: String)
}

// MARK: - HabitCreationViewController
final class HabitCreationViewController: UIViewController {
    
    weak var delegate: HabitCreationViewControllerDelegate?
    
    var trackerToEdit: Tracker?
    var selectedCategory: String?
    private let completedDaysLabel = UILabel()
    var completedCountForEditedTracker: Int?
    private let trackerStore = TrackerStore()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let errorLabel = UILabel()
    private let stackView = UIStackView()
    
    private let categoryContainerView = UIView()
    private let categoryButton = UIButton(type: .system)
    private let categoryImageView = UIImageView()
    private let lineView = UIView()
    private let scheduleTitleLabel = UILabel()
    private let scheduleValueLabel = UILabel()
    private let schenduleCategoryLabel = UILabel()
    private let scheduleImageView = UIImageView()
    private let scheduleTapArea = UIView()
    
    private let emojiLabel = UILabel()
    private lazy var emojiCollectionView: UICollectionView = {
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.minimumInteritemSpacing = 5
        emojiLayout.itemSize = CGSize(width: 52, height: 52)
        let emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
        return emojiCollectionView
    }()
    
    private let colorLabel = UILabel()
    
    private lazy var colorCollectionView: UICollectionView = {
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.minimumInteritemSpacing = 5
        colorLayout.minimumLineSpacing = 0
        colorLayout.itemSize = CGSize(width: 52, height: 52)
        let colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        return colorCollectionView
    }()
    
    
    private var selectedColorIndex: IndexPath?
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    private var selectedColor: String = "Color4"
    private var selectedEmoji: String = "😪"
    
    private let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [String] = ["color1", "color2", "color3", "color4", "green5", "color6", "color7", "color8", "color9", "color10", "color11", "color12", "color13", "color14", "color15", "color16", "color17", "color18"]
    
    private var selectedDays: [WeekDay] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        if let tracker = trackerToEdit {
            configureForEditing(tracker)
        }
        
        hideKeyboardWhenTappedAround()
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        errorLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -96),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        titleLabel.text = "Новая привычка"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "blackDay")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        completedDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        completedDaysLabel.font = UIFont(name: "SFPro-Medium", size: 32) ?? .systemFont(ofSize: 32, weight: .bold)
        completedDaysLabel.textColor = UIColor(named: "blackDay")
        completedDaysLabel.textAlignment = .center
        completedDaysLabel.isHidden = true
        contentView.addSubview(completedDaysLabel)
        
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.textColor = UIColor(named: "blackDay")
        nameTextField.font = UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        nameTextField.layer.cornerRadius = 16
        nameTextField.backgroundColor = UIColor(named: "backgroundDay")
        nameTextField.borderStyle = .none
        nameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        
        let clearButton = UIButton(type: .system)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .yPgray
        clearButton.addTarget(self, action: #selector(clearSearchText), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        
        nameTextField.rightView = clearButton
        nameTextField.rightViewMode = .whileEditing
        nameTextField.clearButtonMode = .never
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = UIColor(.yPred)
        errorLabel.font = UIFont.systemFont(ofSize: 15)
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorLabel.numberOfLines = 0
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(errorLabel)
        contentView.addSubview(stackView)
        
        categoryContainerView.translatesAutoresizingMaskIntoConstraints = false
        categoryContainerView.backgroundColor = UIColor(named: "backgroundDay")
        categoryContainerView.layer.cornerRadius = 16
        contentView.addSubview(categoryContainerView)
        
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.setTitle("Категория", for: .normal)
        categoryButton.setTitleColor(UIColor(named: "blackDay"), for: .normal)
        categoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        categoryButton.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 17)
        categoryButton.contentHorizontalAlignment = .left
        categoryContainerView.addSubview(categoryButton)
        categoryButton.addTarget(self, action: #selector(openCategory), for: .touchUpInside)
        
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        categoryImageView.image = UIImage(named: "сhevron")
        categoryContainerView.addSubview(categoryImageView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor(.yPgray)
        categoryContainerView.addSubview(lineView)
        
        scheduleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleTitleLabel.text = "Расписание"
        scheduleTitleLabel.textColor = UIColor(named: "blackDay")
        categoryContainerView.addSubview(scheduleTitleLabel)
        
        scheduleValueLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleValueLabel.textColor = UIColor(.yPgray)
        scheduleValueLabel.text = formatSelectedDays(selectedDays)
        categoryContainerView.addSubview(scheduleValueLabel)
        
        schenduleCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        schenduleCategoryLabel.textColor = UIColor(.yPgray)
        schenduleCategoryLabel.text = nil
        schenduleCategoryLabel.font =  UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        schenduleCategoryLabel.numberOfLines = 1
        schenduleCategoryLabel.textAlignment = .left
        categoryContainerView.addSubview(schenduleCategoryLabel)
        
        scheduleImageView.translatesAutoresizingMaskIntoConstraints = false
        scheduleImageView.image = UIImage(named: "сhevron")
        categoryContainerView.addSubview(scheduleImageView)
        
        scheduleTapArea.translatesAutoresizingMaskIntoConstraints = false
        scheduleTapArea.backgroundColor = .clear
        scheduleTapArea.isUserInteractionEnabled = true
        scheduleTapArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openSchedule)))
        categoryContainerView.addSubview(scheduleTapArea)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.text = "Emoji"
        emojiLabel.font = UIFont.boldSystemFont(ofSize: 19)
        contentView.addSubview(emojiLabel)
        
        contentView.addSubview(emojiCollectionView)
        
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.text = "Цвет"
        colorLabel.font = UIFont.boldSystemFont(ofSize: 19)
        contentView.addSubview(colorLabel)
        
        contentView.addSubview(colorCollectionView)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.tintColor = UIColor(.yPred)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "YPred")?.cgColor
        
        createButton.setTitle("Создать", for: .normal)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        createButton.tintColor = UIColor(named: "whiteDay")
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = UIColor(.yPgray)
        createButton.isEnabled = false
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        // MARK: Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            completedDaysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            completedDaysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: completedDaysLabel.bottomAnchor, constant: 30),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryContainerView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            categoryContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            categoryContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryContainerView.heightAnchor.constraint(equalToConstant: 150),
            categoryContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            categoryButton.topAnchor.constraint(equalTo: categoryContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: categoryImageView.leadingAnchor, constant: -8),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            categoryImageView.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            categoryImageView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            categoryImageView.widthAnchor.constraint(equalToConstant: 7),
            categoryImageView.heightAnchor.constraint(equalToConstant: 12),
            
            lineView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            
            scheduleTitleLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 20),
            scheduleTitleLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            
            scheduleValueLabel.centerYAnchor.constraint(equalTo: scheduleTitleLabel.centerYAnchor, constant: 20),
            scheduleValueLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            
            schenduleCategoryLabel.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: -8),
            schenduleCategoryLabel.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor),
            schenduleCategoryLabel.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor),
            
            scheduleImageView.centerYAnchor.constraint(equalTo: scheduleTitleLabel.centerYAnchor),
            scheduleImageView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            scheduleImageView.widthAnchor.constraint(equalToConstant: 7),
            scheduleImageView.heightAnchor.constraint(equalToConstant: 12),
            
            scheduleTapArea.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            scheduleTapArea.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor),
            scheduleTapArea.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor),
            scheduleTapArea.bottomAnchor.constraint(equalTo: categoryContainerView.bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: categoryContainerView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.configureFlowLayout(for: self.emojiCollectionView, itemsPerRow: 6, rows: 3, spacing: 8)
            self.configureFlowLayout(for: self.colorCollectionView, itemsPerRow: 6, rows: 3, spacing: 8)
        }
    }
    
    // MARK: - Actions
    @objc private func openSchedule() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        scheduleVC.setSelectedDays(Set(selectedDays))
        let navVC = UINavigationController(rootViewController: scheduleVC)
        present(navVC, animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func clearSearchText() {
        nameTextField.text = ""
    }
    
    @objc private func createTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        let updatedTracker = Tracker(
            id: trackerToEdit?.id ?? UUID(),
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedDays,
            isPinned: trackerToEdit?.isPinned ?? false
        )
        
        if trackerToEdit != nil {
            trackerStore.updateTracker(updatedTracker)
            
            if let newCategoryTitle = selectedCategory {
                delegate?.didCreateTracker(updatedTracker, categoryTitle: newCategoryTitle)
            }
        } else {
            delegate?.didCreateTracker(updatedTracker, categoryTitle: selectedCategory)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func openCategory() {
        let categoriesVC = CategoriesViewController()
        categoriesVC.delegate = self
        let navVC = UINavigationController(rootViewController: categoriesVC)
        present(navVC, animated: true)
    }
    
    @objc private func textFieldDidChange() {
        if let text = nameTextField.text {
            errorLabel.isHidden = text.count < 38
        }
        updateCreateButtonState()
    }
    
    private func configureForEditing(_ tracker: Tracker) {
        titleLabel.text = "Редактирование привычки"
        
        let completedCount = completedCountForEditedTracker ?? 0
        let dayWord = completedCount.dayText()
        completedDaysLabel.text = "\(completedCount) \(dayWord)"
        completedDaysLabel.isHidden = false
        
        nameTextField.text = tracker.name
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        selectedDays = tracker.schedule
        
        if let categoryTitle = selectedCategory {
            schenduleCategoryLabel.text = categoryTitle
            schenduleCategoryLabel.isHidden = false
        }
        
        scheduleValueLabel.text = formatSelectedDays(selectedDays)
        
        createButton.setTitle("Сохранить", for: .normal)
        createButton.backgroundColor = UIColor(named: "blackDay")
        createButton.isEnabled = true
        
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        
        if let emojiIndex = emojies.firstIndex(of: tracker.emoji) {
            let indexPath = IndexPath(item: emojiIndex, section: 0)
            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        
        if let colorIndex = colors.firstIndex(of: tracker.color) {
            selectedColorIndex = IndexPath(item: colorIndex, section: 0)
            let colorIndexPath = IndexPath(item: colorIndex, section: 0)
            colorCollectionView.reloadItems(at: [colorIndexPath])
        }
    }
    
    @objc private func addTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        let newTracker = Tracker(
            id: trackerToEdit?.id ?? UUID(),
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedDays
        )
        
        if trackerToEdit != nil {
            trackerStore.updateTracker(newTracker)
        } else {
            delegate?.didCreateTracker(newTracker, categoryTitle: selectedCategory)
        }
        
        dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        let hasName = !(nameTextField.text ?? "").isEmpty
        let hasSchedule = !selectedDays.isEmpty
        let hasColor = !selectedColor.isEmpty
        let hasEmoji = !selectedEmoji.isEmpty
        createButton.backgroundColor = (hasName && hasSchedule && hasColor && hasEmoji) ? UIColor(named: "blackDay") : UIColor(.yPgray)
        createButton.isEnabled = hasName && hasSchedule && hasColor && hasEmoji
    }
    
    private func formatSelectedDays(_ days: [WeekDay]) -> String {
        guard !days.isEmpty else { return "" }
        if days.count == WeekDay.allCases.count {
            return "Каждый день"
        }
        let sortedDays = days.sorted { $0.rawValue < $1.rawValue }
        let map: [WeekDay: String] = [.monday:"Пн", .tuesday:"Вт", .wednesday:"Ср", .thursday:"Чт", .friday:"Пт", .saturday:"Сб", .sunday:"Вс"]
        return sortedDays.compactMap { map[$0] }.joined(separator: ", ")
    }
    
    private func configureFlowLayout(for collectionView: UICollectionView, itemsPerRow: Int, rows: Int, spacing: CGFloat) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let totalSpacing = spacing * CGFloat(itemsPerRow - 1) + collectionView.contentInset.left + collectionView.contentInset.right
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        let totalHeight = (itemWidth * CGFloat(rows)) + (layout.minimumLineSpacing * CGFloat(rows - 1))
        
        if let existingConstraint = collectionView.constraints.first(where: { $0.firstAttribute == .height }) {
            existingConstraint.constant = totalHeight
        } else {
            let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: totalHeight)
            heightConstraint.isActive = true
        }
    }
}

// MARK: - Delegates
extension HabitCreationViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedDays = days
        scheduleValueLabel.text = formatSelectedDays(days)
        updateCreateButtonState()
    }
}

extension HabitCreationViewController: CategoriesViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        schenduleCategoryLabel.text = category
        schenduleCategoryLabel.isHidden = false
    }
}

extension HabitCreationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let stringRange = Range(range, in: currentText) else { return false }
        return currentText.replacingCharacters(in: stringRange, with: string).count <= 38
    }
}

extension HabitCreationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojies.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseId,
                for: indexPath
            ) as? EmojiCell else { return UICollectionViewCell() }
            
            let emoji = emojies[indexPath.item]
            cell.emojiLabel.text = emoji
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseId,
                for: indexPath
            ) as? ColorCell else { return UICollectionViewCell() }
            
            let isChosen = indexPath == selectedColorIndex
            cell.configure(with: colors[indexPath.item], isChosen: isChosen)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojies[indexPath.item]
            updateCreateButtonState()
        } else {
            
            let previousSelected = selectedColorIndex
            
            selectedColorIndex = indexPath
            selectedColor = colors[indexPath.item]
            
            var indexPathsToReload: [IndexPath] = [indexPath]
            if let previous = previousSelected, previous != indexPath {
                indexPathsToReload.append(previous)
            }
            
            collectionView.reloadItems(at: indexPathsToReload)
            updateCreateButtonState()
        }
    }
}

#Preview {
    HabitCreationViewController()
}

