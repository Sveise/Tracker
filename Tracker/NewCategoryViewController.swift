//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 21.10.2025.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(_ category: String)
}

final class NewCategoryViewController: UIViewController {
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        updateDoneButtonState()
    }
    
    private func setupUI() {
        titleLabel.text = "Новая категория"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        textField.placeholder = "Введите название категории"
        textField.textColor = UIColor(named: "blackDay")
        textField.font = UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "backgroundDay")
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .blackDay
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func doneTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        delegate?.didCreateCategory(text)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateDoneButtonState()
    }
    
    private func updateDoneButtonState() {
        let hasText = !(textField.text ?? "").isEmpty
        
        doneButton.backgroundColor = (hasText) ? UIColor(named: "blackDay") : UIColor(.yPgray)
        doneButton.isEnabled = hasText
    }
}

extension NewCategoryViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

#Preview {
    NewCategoryViewController()
}
