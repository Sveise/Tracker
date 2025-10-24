//
//  ViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 13.08.2025.
//

import UIKit
import CoreData

final class TrackersViewController: UIViewController {
    
    // MARK: - Stores
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    
    // MARK: - Init
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("Unable to access AppDelegate")
            self.init(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
            return
        }
        let context = appDelegate.coreDataStack.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
        self.trackerStore = TrackerStore(context: context)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let context = appDelegate.coreDataStack.persistentContainer.viewContext
        self.categoryStore = TrackerCategoryStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
        self.trackerStore = TrackerStore(context: context)
        super.init(coder: coder)
    }
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = [] {
        didSet { updatePlaceholderVisibility() }
    }
    
    private var trackers: [Tracker] = []
    
    private var records: [TrackerRecord] = [] {
        didSet { updatePlaceholderVisibility() }
    }
    
    private var pinnedTrackers: [Tracker] = []
    
    private var selectedTracker: Tracker?
    private var selectedIndexPath: IndexPath?
    
    private var filteredCategories: [TrackerCategory] {
        var resultCategories: [TrackerCategory] = []
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers)
            resultCategories.append(pinnedCategory)
        }
        
        let regularCategories = categories.filter { category in
            let displayedTrackers = displayedTrackers(for: category)
            return !displayedTrackers.isEmpty && category.title != "Закрепленные"
        }
        
        resultCategories.append(contentsOf: regularCategories)
        return resultCategories
    }
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let notFoundImageView = UIImageView()
    private let notFoundLabel = UILabel()
    private let trackerLabel = UILabel()
    private let searchIcon = UIImageView()
    private let searchView = UIView()
    private let searchTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let placeholderLabel = UILabel()
    private let placeholderImage = UIImageView()
    private let addButton = UIButton(type: .system)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 9
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        cv.register(TrackerHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: TrackerHeaderView.identifier)
        return cv
    }()
    
    var currentDate: Date = Date()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        
        trackers = trackerStore.getAllTrackers()
        loadPinnedTrackers()
        setupUI()
        setupConstraints()
        loadData()
        
        updatePlaceholderVisibility()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Data
    private func loadData() {
        categories = categoryStore.getAllCategories()
        records = recordStore.getAllRecords()
        loadPinnedTrackers()
    }
    
    private func loadPinnedTrackers() {
        pinnedTrackers = trackers.filter { $0.isPinned }
    }
    
    private func saveCategory(title: String, trackers: [Tracker]) {
        if categoryStore.getAllCategories().contains(where: { $0.title == title }) {
            categoryStore.updateCategory(title: title, with: trackers)
        } else {
            categoryStore.createCategory(title: title, trackers: trackers)
        }
        loadData()
        collectionView.reloadData()
    }
    
    private func addRecord(_ record: TrackerRecord) {
        recordStore.addRecord(record)
        records = recordStore.getAllRecords()
    }
    
    private func removeRecord(trackerId: UUID, date: Date) {
        recordStore.deleteRecord(trackerId: trackerId, date: date)
        records = recordStore.getAllRecords()
    }
    
    // MARK: - Pin/Unpin Methods
    private func togglePin(for tracker: Tracker) {
        trackerStore.togglePin(for: tracker)
        trackers = trackerStore.getAllTrackers()
        loadPinnedTrackers()
        collectionView.reloadData()
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        let trackerRecords = records.filter { $0.trackerId == tracker.id }
        for record in trackerRecords {
            recordStore.deleteRecord(trackerId: record.trackerId, date: record.date)
        }
        
        for category in categories {
            let updatedTrackers = category.trackers.filter { $0.id != tracker.id }
            if updatedTrackers != category.trackers {
                categoryStore.updateCategory(title: category.title, with: updatedTrackers)
            }
        }
        
        loadData()
        collectionView.reloadData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar()
        setupAddButton()
        setupTrackerLabel()
        setupDatePicker()
        setupSearch()
        setupPlaceholder()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupTrackerLabel() {
        trackerLabel.text = "Трекеры"
        trackerLabel.textColor = UIColor(named: "blackDay")
        trackerLabel.font = UIFont(name: "SFPro-Bold", size: 34) ?? .boldSystemFont(ofSize: 34)
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
    }
    
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.date = currentDate
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
    }
    
    private func setupAddButton() {
        addButton.setImage(UIImage(named: "Add tracker"), for: .normal)
        addButton.tintColor = .black
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        view.addSubview(addButton)
    }
    
    private func setupSearch() {
        searchView.backgroundColor = UIColor(named: "search")
        searchView.layer.cornerRadius = 10
        searchView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchView)
        
        searchIcon.tintColor = UIColor(.yPgray)
        searchIcon.image = UIImage(systemName: "magnifyingglass")
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchView.addSubview(searchIcon)
        
        searchTextField.placeholder = "Поиск"
        searchTextField.textColor = UIColor(named: "YPgray")
        searchTextField.font = UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        searchView.addSubview(searchTextField)
    }
    
    private func setupPlaceholder() {
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = UIFont(name: "SFPro-Regular", size: 12)
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = UIColor(named: "blackDay")
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        placeholderImage.image = UIImage(named: "error")
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImage)
        
        notFoundImageView.image = UIImage(named: "nothingFound")
        notFoundImageView.contentMode = .scaleAspectFit
        notFoundImageView.translatesAutoresizingMaskIntoConstraints = false
        notFoundImageView.isHidden = true
        view.addSubview(notFoundImageView)
        
        notFoundLabel.text = "Ничего не найдено"
        notFoundLabel.font = UIFont(name: "SFPro-Regular", size: 12)
        notFoundLabel.textColor = UIColor(named: "blackDay")
        notFoundLabel.textAlignment = .center
        notFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        notFoundLabel.isHidden = true
        view.addSubview(notFoundLabel)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42),
            
            trackerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchView.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchView.heightAnchor.constraint(equalToConstant: 36),
            
            searchIcon.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            searchIcon.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 8),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            
            searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            notFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            notFoundImageView.widthAnchor.constraint(equalToConstant: 80),
            notFoundImageView.heightAnchor.constraint(equalToConstant: 80),
            
            notFoundLabel.topAnchor.constraint(equalTo: notFoundImageView.bottomAnchor, constant: 8),
            notFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateUI()
        updatePlaceholderVisibility()
    }
    
    @objc private func searchTextChanged() {
        updateUI()
        updatePlaceholderVisibility()
    }
    
    @objc private func addTapped() {
        let habitVC = HabitCreationViewController()
        habitVC.delegate = self
        let navVC = UINavigationController(rootViewController: habitVC)
        present(navVC, animated: true)
    }
    
    private func createContextMenu(for tracker: Tracker) -> UIMenu {
        let pinTitle = tracker.isPinned ? "Открепить" : "Закрепить"
        let pinAction = UIAction(title: pinTitle) { [weak self] _ in
            self?.togglePin(for: tracker)
        }
        
        let editAction = UIAction(title: "Редактировать") { [weak self] _ in
            self?.editTracker(tracker)
        }
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
            self?.showDeleteConfirmation(for: tracker)
        }
        
        return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
    }
    
    private func editTracker(_ tracker: Tracker) {
        let habitVC = HabitCreationViewController()
        habitVC.delegate = self
        habitVC.trackerToEdit = tracker
        
        if let category = categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
            habitVC.selectedCategory = category.title
        }
        
        let count = records.filter { $0.trackerId == tracker.id }.count
        habitVC.completedCountForEditedTracker = count
        
        let navVC = UINavigationController(rootViewController: habitVC)
        present(navVC, animated: true)
    }
    
    private func showDeleteConfirmation(for tracker: Tracker) {
        let alert = UIAlertController(
            title: "Уверены что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController,
           let indexPath = selectedIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func addNewTracker(_ tracker: Tracker, to categoryTitle: String?) {
        guard let categoryTitle = categoryTitle else {
            updatePlaceholderVisibility()
            return
        }
        
        var updatedTrackers: [Tracker] = []
        
        if let existing = categories.first(where: { $0.title == categoryTitle }) {
            updatedTrackers = existing.trackers + [tracker]
        } else {
            updatedTrackers = [tracker]
        }
        
        saveCategory(title: categoryTitle, trackers: updatedTrackers)
    }
    
    private func isTrackerActive(_ tracker: Tracker, on date: Date) -> Bool {
        guard !tracker.schedule.isEmpty else { return true }
        return tracker.schedule.contains(WeekDay.from(date: date))
    }
    
    private func displayedTrackers(for category: TrackerCategory) -> [Tracker] {
        var trackers = category.trackers.filter { isTrackerActive($0, on: currentDate) }
        if let search = searchTextField.text, !search.isEmpty {
            trackers = trackers.filter { $0.name.lowercased().contains(search.lowercased()) }
        }
        return trackers
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }
    
    private func updatePlaceholderVisibility() {
        let allTrackers = filteredCategories.flatMap { displayedTrackers(for: $0) }
        let hasTrackers = !allTrackers.isEmpty
        let isSearching = !(searchTextField.text?.isEmpty ?? true)
        
        let nothingFound = isSearching && allTrackers.isEmpty
        
        placeholderLabel.isHidden = hasTrackers || isSearching
        placeholderImage.isHidden = hasTrackers || isSearching
        notFoundLabel.isHidden = !nothingFound
        notFoundImageView.isHidden = !nothingFound
        collectionView.isHidden = nothingFound || !hasTrackers
    }
    
    private func updateUI() {
        collectionView.reloadData()
    }
    
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        records.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func toggleCompletion(for tracker: Tracker, on date: Date) {
        guard date <= Date() else { return }
        
        if isTrackerCompleted(tracker, on: date) {
            recordStore.deleteRecord(trackerId: tracker.id, date: date)
        } else {
            recordStore.addRecord(TrackerRecord(trackerId: tracker.id, date: date))
        }
        
        records = recordStore.getAllRecords()
        
        for section in 0..<filteredCategories.count {
            let trackersInSection = displayedTrackers(for: filteredCategories[section])
            if let item = trackersInSection.firstIndex(where: { $0.id == tracker.id }) {
                let indexPath = IndexPath(item: item, section: section)
                collectionView.reloadItems(at: [indexPath])
                break
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPath.section < filteredCategories.count else { return nil }
        
        let category = filteredCategories[indexPath.section]
        let trackersInSection = displayedTrackers(for: category)
        guard indexPath.item < trackersInSection.count else { return nil }
        
        let tracker = trackersInSection[indexPath.item]
        selectedTracker = tracker
        selectedIndexPath = indexPath
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            return self?.createContextMenu(for: tracker)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        guard let indexPath = selectedIndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell.containerView, parameters: parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {
        selectedTracker = nil
        selectedIndexPath = nil
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionAnimating?) {
        DispatchQueue.main.async {
            self.selectedTracker = nil
            self.selectedIndexPath = nil
        }
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { filteredCategories.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedTrackers(for: filteredCategories[section]).count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier,
                                                            for: indexPath) as? TrackerCell else {
            assertionFailure("Failed to dequeue TrackerCell")
            return UICollectionViewCell()
        }
        let tracker = displayedTrackers(for: filteredCategories[indexPath.section])[indexPath.item]
        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        cell.configure(
            with: tracker,
            selectedDate: currentDate,
            isCompleted: isCompleted,
            completedCount: records.filter { $0.trackerId == tracker.id }.count
        )
        cell.onCompletionToggled = { [weak self] tracker in
            guard let self = self else { return }
            self.toggleCompletion(for: tracker, on: self.currentDate)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 32 - 9) / 2
        return CGSize(width: width, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeaderView.identifier,
            for: indexPath
        ) as? TrackerHeaderView else {
            assertionFailure("Failed to dequeue TrackerHeaderView")
            return UICollectionReusableView()
        }
        header.titleLabel.text = filteredCategories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 50)
    }
}

// MARK: - HabitCreationViewControllerDelegate
extension TrackersViewController: HabitCreationViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        print("Выбрана категория: \(category)")
    }
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String?) {
        addNewTracker(tracker, to: categoryTitle)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        trackers = trackerStore.getAllTrackers()
        collectionView.reloadData()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        categories = categoryStore.getAllCategories()
        collectionView.reloadData()
    }
}

// MARK: - TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        records = recordStore.getAllRecords()
        collectionView.reloadData()
    }
}

extension TrackersViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showLoadingIndicator()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        hideLoadingIndicator()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            hideLoadingIndicator()
        }
    }
}

#Preview {
    TrackersViewController()
}
