//
//  StatsViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 04.11.2025.
//

import UIKit

final class StatsViewController: UIViewController {
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .blackDay
        return label
    }()
    
    private let imageStats: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stats 1")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        
        view.addSubview(textLabel)
        view.addSubview(imageStats)
        setupConstraits()
        
    }
    
    private func setupConstraits() {
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            imageStats.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageStats.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageStats.widthAnchor.constraint(equalToConstant: 80),
            imageStats.heightAnchor.constraint(equalToConstant: 80)
            ])
    }
}

#Preview {
    StatsViewController()
}
