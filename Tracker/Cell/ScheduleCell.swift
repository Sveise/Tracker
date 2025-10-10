//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Svetlana Varenova on 04.09.2025.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    static let identifier = "ScheduleCell"
    
    let dayLabel = UILabel()
    let daySwitch = UISwitch()
    
    var switchChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        daySwitch.onTintColor = .systemBlue
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)
        
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        daySwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    @objc private func switchValueChanged() {
        switchChanged?(daySwitch.isOn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
