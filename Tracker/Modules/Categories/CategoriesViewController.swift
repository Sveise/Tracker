//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Svetlana Varenova on 21.10.2025.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoriesViewController: UIViewController {
    
    weak var delegate: CategoriesViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let containerView = UIView()
    private let tableView = UITableView()
    private let placeholderLabel = UILabel()
    private let placeholderImage = UIImageView()
    private let addButton = UIButton(type: .system)
    
    private let viewModel: CategoriesViewModel
    
    // MARK: - Init
    init(viewModel: CategoriesViewModel = CategoriesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        
        setupBindings()
        setupTitleLabel()
        setupAddButton()
        setupTableViewContainer()
        setupPlaceholder()
        updatePlaceholderVisibility()
        
        setupContextMenuInteraction()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                             .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.updatePlaceholderVisibility()
        }
        
        viewModel.onCategorySelected = { [weak self] category in
            self?.delegate?.didSelectCategory(category)
            self?.dismiss(animated: true)
        }
    }
    
    // MARK: - Actions
    @objc private func addCategoryTapped() {
        let newVC = NewCategoryViewController()
        newVC.delegate = self
        present(newVC, animated: true)
    }
    
    private func setupContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        tableView.addInteraction(interaction)
    }
    
    // MARK: - UI Setup
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .blackDay
        titleLabel.textAlignment = .center
        titleLabel.text = "Категория"
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupTableViewContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        view.addSubview(containerView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupAddButton() {
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addButton.backgroundColor = .black
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPlaceholder() {
        placeholderImage.image = UIImage(named: "error")
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImage)
        
        placeholderLabel.text = "Привычки и события можно\nобъединить по смыслу"
        placeholderLabel.font = UIFont(name: "SFPro-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = .blackDay
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func updatePlaceholderVisibility() {
        let shouldShow = viewModel.shouldShowPlaceholder
        placeholderImage.isHidden = !shouldShow
        placeholderLabel.isHidden = !shouldShow
        containerView.isHidden = shouldShow
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let configuration = viewModel.getCellConfiguration(for: indexPath.row)
        cell.configure(with: configuration)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        tableView.reloadData()
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension CategoriesViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let tableViewLocation = interaction.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: tableViewLocation) else { return nil }
        
        let category = viewModel.getCategoryForContextMenu(at: indexPath.row)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                guard let self = self else { return }
                let editVC = EditCategoryViewController(category: category, store: self.viewModel.store)
                editVC.modalPresentationStyle = .pageSheet
                self.present(editVC, animated: true)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                self?.showDeleteConfirmation(for: category)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let location = interaction.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location),
              let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        return UITargetedPreview(view: cell)
    }
    
    private func showDeleteConfirmation(for category: TrackerCategory) {
        let alert = UIAlertController(
            title: "Эта категория точно не нужна?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive
        ) { [weak self] _ in
            if let index = self?.viewModel.findCategoryIndex(category) {
                self?.viewModel.deleteCategory(at: index)
            }
        }
        
        let cancelAction = UIAlertAction(
            title: "Отменить",
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - Delegates
extension CategoriesViewController: NewCategoryViewControllerDelegate {
    func didCreateCategory(_ category: String) {
        viewModel.addCategory(title: category)
    }
}

#Preview {
    CategoriesViewController()
}
