//
//  EmojiCell.swift
//  Tracker
//
//  Created by Svetlana Varenova on 26.09.2025.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let reuseId = "EmojiCell"
    
    let emojiLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .clear
        
        emojiLabel.font = .systemFont(ofSize: 31)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
                self.contentView.backgroundColor = self.isSelected ? UIColor.systemGray5 : .clear
            }
        }
    }
}
