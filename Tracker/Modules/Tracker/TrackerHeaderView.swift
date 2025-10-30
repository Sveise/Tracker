//
//  TrackerHeaderView.swift
//  Tracker
//
//  Created by Svetlana Varenova on 02.09.2025.
//

import UIKit

final class TrackerHeaderView: UICollectionReusableView {
    static let identifier = "TrackerHeaderView"
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .boldSystemFont(ofSize: 19)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
