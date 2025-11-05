//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 02.09.2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let containerView = UIView()
    private let tableView = UITableView()
    private var selectedDays: Set<WeekDay> = []
    private let doneButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteDay
        setupTitleLabel()
        setupTableView()
        setupDoneButton()
    }
    
    func setSelectedDays(_ days: Set<WeekDay>) {
        selectedDays = days
        tableView.reloadData()
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .blackDay
        titleLabel.textAlignment = .center
        titleLabel.text = "Расписание"
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
    
    private func setupTableView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        view.addSubview(containerView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .backgroundDay
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        updateContainerHeight()
    }
    
    private func updateContainerHeight() {
        let rowHeight: CGFloat = 75
        let numberOfRows = CGFloat(WeekDay.allCases.count)
        let totalHeight = rowHeight * numberOfRows
        
        containerView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.setTitleColor(.whiteDay, for: .normal)
        doneButton.backgroundColor = .blackDay
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    @objc private func doneTapped() {
        delegate?.didSelectDays(Array(selectedDays))
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.identifier,
            for: indexPath
        ) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let day = WeekDay.allCases[indexPath.row]
        cell.dayLabel.text = day.title
        cell.daySwitch.isOn = selectedDays.contains(day)
        
        cell.switchChanged = { [weak self] isOn in
            guard let self else { return }
            if isOn {
                self.selectedDays.insert(day)
            } else {
                self.selectedDays.remove(day)
            }
        }
        
        configureCellAppearance(cell, for: indexPath)
        
        return cell
    }
    
    private func configureCellAppearance(_ cell: UITableViewCell, for indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .backgroundDay
        
        if numberOfRows == 1 {
            backgroundView.layer.cornerRadius = 16
            backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            switch indexPath.row {
            case 0:
                backgroundView.layer.cornerRadius = 16
                backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case numberOfRows - 1:
                backgroundView.layer.cornerRadius = 16
                backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            default:
                backgroundView.layer.cornerRadius = 0
            }
        }
        
        cell.backgroundView = backgroundView
        cell.selectedBackgroundView = UIView()
        
        if indexPath.row < numberOfRows - 1 {
            let separator = UIView()
            separator.backgroundColor = .lightGray.withAlphaComponent(0.3)
            separator.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

#Preview {
    ScheduleViewController()
}
