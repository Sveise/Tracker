//
//  ColorCell.swift
//  Tracker
//
//  Created by Svetlana Varenova on 28.09.2025.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseId = "ColorCell"
    private let colorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
        colorView.layer.cornerRadius = 8
        colorView.clipsToBounds = true

        layer.cornerRadius = 8
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with colorName: String, isChosen: Bool) {
        colorView.backgroundColor = UIColor(named: colorName)
        layer.borderColor = isChosen ? colorView.backgroundColor?.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
        layer.borderWidth = isChosen ? 3 : 0
    }
}

