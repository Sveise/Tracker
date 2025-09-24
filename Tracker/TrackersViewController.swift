//
//  ViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 13.08.2025.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = [] {
        didSet {
            TrackerStorage.shared.saveCategories(categories)
            updatePlaceholderVisibility()
        }
    }
    
    private var records: [TrackerRecord] = [] {
        didSet {
            TrackerStorage.shared.saveRecords(records)
        }
    }
    
    private let trackerLabel = UILabel()
    private let searchIcon = UIImageView()
    private let searchView = UIView()
    private let searchTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let placeholderLabel = UILabel()
    private let placeholderImage = UIImageView()
    private let addButton = UIButton(type: .system)
    var currentDate: Date = Date()
    
    private var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupUI()
        setupConstraints()
        
        categories = TrackerStorage.shared.loadCategories()
        records = TrackerStorage.shared.loadRecords()
        
        updatePlaceholderVisibility()
        
        hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewTracker(_:)),
            name: .didCreateTracker,
            object: nil
        )
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
        placeholderLabel.font = .systemFont(ofSize: 12)
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
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 9
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeaderView.identifier)
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Add Button
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42),
            
            // Tracker Label
            trackerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerLabel.widthAnchor.constraint(equalToConstant: 254),
            trackerLabel.heightAnchor.constraint(equalToConstant: 41),
            
            // Date Picker
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            
            // Search View
            searchView.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchView.heightAnchor.constraint(equalToConstant: 36),
            
            // Search Icon
            searchIcon.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            searchIcon.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 8),
            searchIcon.widthAnchor.constraint(equalToConstant: 15.63),
            searchIcon.heightAnchor.constraint(equalToConstant: 15.78),
            
            // Search Text Field
            searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -8),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Placeholder Image
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            // Placeholder Label
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
        let navVC = UINavigationController(rootViewController: habitVC)
        present(navVC, animated: true)
    }
    
    @objc private func handleNewTracker(_ notification: Notification) {
        guard let tracker = notification.object as? Tracker else { return }
        
        if let index = categories.firstIndex(where: { $0.title == "Важное" }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            categories[index] = TrackerCategory(title: "Важное", trackers: updatedTrackers)
        } else {
            categories.append(TrackerCategory(title: "Важное", trackers: [tracker]))
        }
        
        collectionView.reloadData()
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
        guard isViewLoaded else { return } 
        let hasTrackersToShow = categories.flatMap { displayedTrackers(for: $0) }.count > 0
        placeholderLabel.isHidden = hasTrackersToShow
        placeholderImage.isHidden = hasTrackersToShow
        collectionView.isHidden = !hasTrackersToShow
    }
    
    private func updateUI() {
        collectionView.reloadData()
    }
    
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        records.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func toggleCompletion(for tracker: Tracker, on date: Date) {
        guard date <= Date() else { return }
        
        if let index = records.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            records.remove(at: index)
        } else {
            records.append(TrackerRecord(trackerId: tracker.id, date: date))
        }
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { categories.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedTrackers(for: categories[section]).count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier,
                                                      for: indexPath) as! TrackerCell
        let tracker = displayedTrackers(for: categories[indexPath.section])[indexPath.item]
        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        cell.configure(with: tracker, selectedDate: currentDate, isCompleted: isCompleted, completedCount: records.filter { $0.trackerId == tracker.id }.count)
        cell.onCompletionToggled = { [weak self] tracker in
            self?.toggleCompletion(for: tracker, on: self?.currentDate ?? Date())
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 32 - 9) / 2
        return CGSize(width: width, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: TrackerHeaderView.identifier,
                                                                     for: indexPath) as! TrackerHeaderView
        header.titleLabel.text = categories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 50)
    }
}

// MARK: - Keyboard Dismiss
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

#Preview {TrackersViewController()}

