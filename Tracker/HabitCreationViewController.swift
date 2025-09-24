//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 02.09.2025.
//

import UIKit

// MARK: - Notification
extension Notification.Name {
    static let didCreateTracker = Notification.Name("didCreateTracker")
}

// MARK: - Protocol
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}

// MARK: - HabitCreationViewController
final class HabitCreationViewController: UIViewController {
    
    private let titleLabel = UILabel()
    
    private let nameTextField = UITextField()
    private let errorLabel = UILabel()
    
    private let stackView = UIStackView()
    
    private let categoryContainerView = UIView()
    private let categoryButton = UIButton(type: .system)
    private let categoryImageView = UIImageView()
    private let lineView = UIView()
    private let scheduleTitleLabel = UILabel()
    private let scheduleValueLabel = UILabel()
    private let scheduleImageView = UIImageView()
    private let scheduleTapArea = UIView()
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    private var selectedColor: String = "Color selection 5"
    private var selectedEmoji: String = "😪"
    private var selectedDays: [WeekDay] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        hideKeyboardWhenTappedAround()
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        errorLabel.isHidden = true
    }
    
    private func updateCreateButtonState() {
        let hasName = !(nameTextField.text ?? "").isEmpty
        let hasSchedule = !selectedDays.isEmpty
        
        if hasName && hasSchedule {
            createButton.backgroundColor = UIColor(named: "blackDay")
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(.yPgray)
            createButton.isEnabled = false
        }
    }
    
    private func formatSelectedDays(_ days: [WeekDay]) -> String {
        guard !days.isEmpty else { return "" }
        let sortedDays = days.sorted { $0.rawValue < $1.rawValue }
        let dayAbbreviations = sortedDays.map { day -> String in
            switch day {
            case .monday: return "Пн"
            case .tuesday: return "Вт"
            case .wednesday: return "Ср"
            case .thursday: return "Чт"
            case .friday: return "Пт"
            case .saturday: return "Сб"
            case .sunday: return "Вс"
            }
        }
        return dayAbbreviations.joined(separator: ", ")
    }
    
    private func setupUI() {

        titleLabel.text = "Новая привычка"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "blackDay")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.textColor = UIColor(named: "blackDay")
        nameTextField.font = UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        nameTextField.layer.cornerRadius = 16
        nameTextField.backgroundColor = UIColor(named: "backgroundDay")
        nameTextField.borderStyle = .none
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.rightView = rightPaddingView
        nameTextField.rightViewMode = .always
        nameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = UIColor(.yPred)
        errorLabel.font = UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorLabel.numberOfLines = 0
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(errorLabel)
        view.addSubview(stackView)
        
        categoryContainerView.translatesAutoresizingMaskIntoConstraints = false
        categoryContainerView.backgroundColor = UIColor(named: "backgroundDay")
        categoryContainerView.layer.cornerRadius = 16
        view.addSubview(categoryContainerView)
        
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.setTitle("Категория", for: .normal)
        categoryButton.titleLabel?.font = UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        categoryButton.setTitleColor(UIColor(named: "blackDay"), for: .normal)
        categoryButton.contentHorizontalAlignment = .left
        categoryContainerView.addSubview(categoryButton)
        
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        categoryImageView.image = UIImage(named: "сhevron")
        categoryImageView.tintColor = UIColor(.yPgray)
        categoryContainerView.addSubview(categoryImageView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor(.yPgray)
        categoryContainerView.addSubview(lineView)
        
        scheduleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleTitleLabel.text = "Расписание"
        scheduleTitleLabel.font = UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        scheduleTitleLabel.textColor = UIColor(named: "blackDay")
        categoryContainerView.addSubview(scheduleTitleLabel)
        
        scheduleValueLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleValueLabel.font = UIFont(name: "SFPro-Regular", size: 17) ?? .systemFont(ofSize: 17)
        scheduleValueLabel.textColor = UIColor(.yPgray)
        scheduleValueLabel.text = formatSelectedDays(selectedDays)
        categoryContainerView.addSubview(scheduleValueLabel)
        
        scheduleImageView.translatesAutoresizingMaskIntoConstraints = false
        scheduleImageView.image = UIImage(named: "сhevron")
        scheduleImageView.tintColor = UIColor(.yPgray)
        categoryContainerView.addSubview(scheduleImageView)
        
        scheduleTapArea.translatesAutoresizingMaskIntoConstraints = false
        scheduleTapArea.backgroundColor = .clear
        scheduleTapArea.isUserInteractionEnabled = true
        scheduleTapArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openSchedule)))
        categoryContainerView.addSubview(scheduleTapArea)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.tintColor = UIColor(.yPred)
        cancelButton.widthAnchor.constraint(equalToConstant: 166).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "YPred")?.cgColor
        
        createButton.setTitle("Создать", for: .normal)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        createButton.widthAnchor.constraint(equalToConstant: 161).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        createButton.tintColor = UIColor(named: "whiteDay")
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = UIColor(.yPgray)
        createButton.isEnabled = false
        
        createButton.setTitleColor(UIColor(named: "whiteDay"), for: .normal)
        createButton.setTitleColor(UIColor(named: "whiteDay"), for: .disabled)
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 343),
            
            categoryContainerView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            categoryContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryContainerView.widthAnchor.constraint(equalToConstant: 343),
            categoryContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            categoryButton.topAnchor.constraint(equalTo: categoryContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: categoryImageView.leadingAnchor, constant: -8),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            categoryImageView.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            categoryImageView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            categoryImageView.widthAnchor.constraint(equalToConstant: 7),
            categoryImageView.heightAnchor.constraint(equalToConstant: 12),
            
            lineView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            
            scheduleTitleLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 26),
            scheduleTitleLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            
            scheduleValueLabel.centerYAnchor.constraint(equalTo: scheduleTitleLabel.centerYAnchor),
            scheduleValueLabel.leadingAnchor.constraint(equalTo: scheduleTitleLabel.trailingAnchor, constant: 8),
            scheduleValueLabel.trailingAnchor.constraint(equalTo: scheduleImageView.leadingAnchor, constant: -8),
            
            scheduleImageView.centerYAnchor.constraint(equalTo: scheduleTitleLabel.centerYAnchor),
            scheduleImageView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            scheduleImageView.widthAnchor.constraint(equalToConstant: 7),
            scheduleImageView.heightAnchor.constraint(equalToConstant: 12),
            
            scheduleTapArea.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            scheduleTapArea.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor),
            scheduleTapArea.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor),
            scheduleTapArea.bottomAnchor.constraint(equalTo: categoryContainerView.bottomAnchor),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func openSchedule() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        scheduleVC.setSelectedDays(Set(selectedDays))
        let navVC = UINavigationController(rootViewController: scheduleVC)
        present(navVC, animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        let tracker = Tracker(
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedDays
        )
        
        NotificationCenter.default.post(name: .didCreateTracker, object: tracker)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        if let text = nameTextField.text {
            let shouldShowError = text.count >= 38
            if errorLabel.isHidden != !shouldShowError {
                errorLabel.isHidden = !shouldShowError
                UIView.animate(withDuration: 0.25) {
                    self.stackView.layoutIfNeeded()
                }
            }
        }
        updateCreateButtonState()
    }
}

// MARK: - Schedule Delegate
extension HabitCreationViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedDays = days
        scheduleValueLabel.text = formatSelectedDays(days)
        updateCreateButtonState()
    }
}

extension HabitCreationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 38
    }
}

#Preview {
    HabitCreationViewController()
}

