//
//  TrackerCell.swift
//  Tracker
//
//  Created by Svetlana Varenova on 02.09.2025.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    let containerView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let daysLabel = UILabel()
    private let completionButton = UIButton(type: .system)
    
    // MARK: - Properties
    static let identifier = "TrackerCell"
    private var tracker: Tracker?
    private var selectedDate: Date = Date()
    var onCompletionToggled: ((Tracker) -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = UIFont.systemFont(ofSize: 13)
        emojiLabel.backgroundColor = .colorBorder
        emojiLabel.textAlignment = .center
        emojiLabel.clipsToBounds = true
        emojiLabel.layer.cornerRadius = 12
        containerView.addSubview(emojiLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 2
        nameLabel.font = UIFont(name: "SFPro-Medium", size: 12) ?? UIFont.systemFont(ofSize: 11, weight: .medium)
        nameLabel.textColor = .white
        containerView.addSubview(nameLabel)
        
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = UIFont(name: "SFPro-Medium", size: 12) ?? UIFont.systemFont(ofSize: 11, weight: .medium)
        daysLabel.textColor = UIColor(named: "blackDay")
        contentView.addSubview(daysLabel)
        
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        completionButton.layer.cornerRadius = 17
        completionButton.addTarget(self, action: #selector(completionButtonTapped), for: .touchUpInside)
        contentView.addSubview(completionButton)
        
        containerView.addSubview(pinImageView)
        
        NSLayoutConstraint.activate([
            // containerView
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            // emojiLabel
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // nameLabel
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // daysLabel
            daysLabel.centerYAnchor.constraint(equalTo: completionButton.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            // completionButton
            completionButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            completionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            completionButton.widthAnchor.constraint(equalToConstant: 34),
            completionButton.heightAnchor.constraint(equalToConstant: 34),
            
            pinImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            pinImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            pinImageView.widthAnchor.constraint(equalToConstant: 8),
            pinImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Configure
    func configure(with tracker: Tracker, selectedDate: Date, isCompleted: Bool, completedCount: Int) {
        self.tracker = tracker
        self.selectedDate = selectedDate
        
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        containerView.backgroundColor = UIColor(named: tracker.color) ?? UIColor.systemGreen
        
        let dayText = completedCount.dayText()
        daysLabel.text = "\(completedCount) \(dayText)"
        
        updateCompletionButton(isCompleted: isCompleted)
        
        pinImageView.isHidden = !tracker.isPinned
    }
    
    // MARK: - Completion Button
    @objc private func completionButtonTapped() {
        guard let tracker = tracker else { return }
        onCompletionToggled?(tracker)
    }
    
    private func updateCompletionButton(isCompleted: Bool) {
        let cellColor = UIColor(named: tracker?.color ?? "green5") ?? UIColor.systemGreen
        
        if isCompleted {
            completionButton.setTitle("✓", for: .normal)
            completionButton.setTitleColor(.white, for: .normal)
            completionButton.backgroundColor = cellColor.withAlphaComponent(0.3)
            completionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        } else {
            completionButton.setTitle("+", for: .normal)
            completionButton.setTitleColor(.white, for: .normal)
            completionButton.backgroundColor = cellColor
            completionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
}

