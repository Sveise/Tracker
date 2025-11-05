//
//  StatsViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 04.11.2025.
//

import UIKit
import CoreData

final class StatsViewController: UIViewController {
    
    // MARK: - Stores
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
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
        self.trackerStore = TrackerStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
        super.init(nibName: nil, bundle: nil)
        self.trackerStore.delegate = self
        self.recordStore.delegate = self
    }
    
    required init?(coder: NSCoder) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let context = appDelegate.coreDataStack.persistentContainer.viewContext
        self.trackerStore = TrackerStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)
        super.init(coder: coder)
    }
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .blackDay
        return label
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stats 1")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blackDay
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setupUI()
        updateStats()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        view.addSubview(statsStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Update Stats
    private func updateStats() {
        let trackers = trackerStore.getAllTrackers()
        let records = recordStore.getAllRecords()
        
        guard !trackers.isEmpty else {
            statsStackView.isHidden = true
            emptyImageView.isHidden = false
            emptyLabel.isHidden = false
            return
        }
        
        statsStackView.isHidden = false
        emptyImageView.isHidden = true
        emptyLabel.isHidden = true
        
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        statsStackView.addArrangedSubview(makeStatCard(title: "Лучший период", value: "\(calculateBestStreak(from: records))"))
        statsStackView.addArrangedSubview(makeStatCard(title: "Идеальные дни", value: "\(calculatePerfectDays(records: records, trackers: trackers))"))
        statsStackView.addArrangedSubview(makeStatCard(title: "Трекеров завершено", value: "\(records.count)"))
        statsStackView.addArrangedSubview(makeStatCard(title: "Среднее значение", value: String(format: "%.1f", calculateAverage(records: records, trackers: trackers))))
    }
    
    // MARK: - Helpers
    
    private func makeStatCard(title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(named: "whiteDay") ?? .systemGray6
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 80)
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2 / UIScreen.main.scale
        shape.path = UIBezierPath(roundedRect: gradient.bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        container.layer.addSublayer(gradient)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(named: "blackDay") ?? .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 34)
        valueLabel.textColor = UIColor(named: "blackDay") ?? .black
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 52),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -32)
        ])
        
        return container
    }
    
    private func calculateBestStreak(from records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        let uniqueDates = Array(Set(records.map { Calendar.current.startOfDay(for: $0.date) })).sorted()
        
        var best = 1
        var current = 1
        
        for i in 1..<uniqueDates.count {
            let prev = uniqueDates[i - 1]
            let curr = uniqueDates[i]
            if Calendar.current.isDate(curr, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: prev)!) {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }
        return best
    }
    
    private func calculatePerfectDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        guard !records.isEmpty else { return 0 }
        let grouped = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date) })
        return grouped.values.filter { $0.count == trackers.count }.count
    }
    
    private func calculateAverage(records: [TrackerRecord], trackers: [Tracker]) -> Double {
        guard !trackers.isEmpty else { return 0 }
        return Double(records.count) / Double(trackers.count)
    }
}

// MARK: - Delegates
extension StatsViewController: TrackerStoreDelegate, TrackerRecordStoreDelegate {
    func didUpdateTrackers() {
        updateStats()
    }
    
    func didUpdateRecords() {
        updateStats()
    }
}

#Preview {
    StatsViewController()
}
