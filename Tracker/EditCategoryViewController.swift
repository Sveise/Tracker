//
//  EditCategoryViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 23.10.2025.
//

import UIKit

final class EditCategoryViewController: UIViewController {
    
    private let store: TrackerCategoryStore
    private let category: TrackerCategory
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    private let clearButton = UIButton(type: .system)
    
    init(category: TrackerCategory, store: TrackerCategoryStore) {
        self.category = category
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setupUI()
        setupClearButton()
    }
    
    private func setupUI() {
        titleLabel.text = "Редактирование категории"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .blackDay
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textField.placeholder = "Введите новое название"
        textField.text = category.title
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .black
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupClearButton() {
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .yPgray
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        
        textField.rightView = clearButton
        textField.rightViewMode = .whileEditing
    }
    
    @objc private func textFieldDidChange() {
        clearButton.isHidden = textField.text?.isEmpty ?? true
    }
    
    @objc private func clearText() {
        textField.text = ""
        clearButton.isHidden = true
    }
    
    @objc private func saveTapped() {
        guard let newName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !newName.isEmpty else { return }
        store.renameCategory(category, newTitle: newName)
        dismiss(animated: true)
    }
}

