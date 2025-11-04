//
//  StatsViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 04.11.2025.
//

import UIKit

final class StatsViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .blackDay
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
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
        
        view.addSubview(titleLabel)
        view.addSubview(imageStats)
        view.addSubview(textLabel)
        setupConstraits()
        
    }
    
    private func setupConstraits() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            imageStats.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageStats.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageStats.widthAnchor.constraint(equalToConstant: 80),
            imageStats.heightAnchor.constraint(equalToConstant: 80),
            
            textLabel.topAnchor.constraint(equalTo: imageStats.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ])
    }
}

#Preview {
    StatsViewController()
}
