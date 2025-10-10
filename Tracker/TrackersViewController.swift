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
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
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
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
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
    
    private func addNewTracker(_ tracker: Tracker) {
        var updatedTrackers: [Tracker] = []

        if let existing = categories.first(where: { $0.title == "Важное" }) {
            updatedTrackers = existing.trackers + [tracker]
        } else {
            updatedTrackers = [tracker]
        }

        saveCategory(title: "Важное", trackers: updatedTrackers)
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
    
    private func updatePlaceholderVisibility() {
        let hasTrackers = categories.flatMap { displayedTrackers(for: $0) }.count > 0
        placeholderLabel.isHidden = hasTrackers
        placeholderImage.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
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

        for section in 0..<categories.count {
            let trackersInSection = displayedTrackers(for: categories[section])
            if let item = trackersInSection.firstIndex(where: { $0.id == tracker.id }) {
                let indexPath = IndexPath(item: item, section: section)
                collectionView.reloadItems(at: [indexPath])
                break
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { categories.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedTrackers(for: categories[section]).count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier,
                                                      for: indexPath) as? TrackerCell else {
            assertionFailure("Failed to dequeue TrackerCell")
            return UICollectionViewCell()
        }
        let tracker = displayedTrackers(for: categories[indexPath.section])[indexPath.item]
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
        header.titleLabel.text = categories[indexPath.section].title
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
    func didCreateTracker(_ tracker: Tracker) {
        addNewTracker(tracker)
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

