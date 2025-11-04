//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 03.11.2025.
//

import UIKit

// MARK: - FilterType
enum FilterType: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case notCompleted = "Не завершенные"
}

// MARK: - FiltersViewControllerDelegate
protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterType)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    var selectedFilter: FilterType = .all
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : UIColor(named: "blackDay") ?? .black
        }
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(named: "backgroundNight") ?? .darkGray :
                UIColor(named: "backgroundDay") ?? .white
        }
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColorsForCurrentTheme()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
        
        view.addSubview(titleLabel)
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        let rowHeight: CGFloat = 75
        let totalHeight = CGFloat(FilterType.allCases.count) * rowHeight
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: totalHeight),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func updateColorsForCurrentTheme() {
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
        
        containerView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(named: "backgroundNight") ?? .darkGray :
                UIColor(named: "backgroundDay") ?? .white
        }
        
        titleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : UIColor(named: "blackDay") ?? .black
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FilterType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = FilterType.allCases[indexPath.row]
        
        cell.textLabel?.text = NSLocalizedString(filter.rawValue, comment: "")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : UIColor(named: "blackDay") ?? .black
        }
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .darkGray : .lightGray
        }
        cell.selectedBackgroundView = selectionView
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        
        if indexPath.row < FilterType.allCases.count - 1 {
            let separator = UIView()
            separator.backgroundColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(white: 0.3, alpha: 1.0) :
                    UIColor(named: "search") ?? .lightGray
            }
            separator.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
        
        cell.accessoryType = filter == selectedFilter ? .checkmark : .none
        cell.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .systemBlue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedFilter = FilterType.allCases[indexPath.row]
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.delegate?.didSelectFilter(self.selectedFilter)
            self.dismiss(animated: true)
        }
    }
}

#Preview {
    FiltersViewController()
}
