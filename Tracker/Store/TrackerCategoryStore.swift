//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Svetlana Varenova on 07.10.2025.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Init
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("❌ Не удалось получить AppDelegate")
        }
        let context = appDelegate.coreDataStack.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup FRC
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        fetchedResultsController = frc
        
        do {
            try frc.performFetch()
        } catch {
            print("❌ Ошибка FRC (TrackerCategory): \(error)")
        }
    }
    
    // MARK: - CRUD
    func createCategory(title: String, trackers: [Tracker] = []) {
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.title = title
        
        let trackerEntities = trackers.map { tracker -> TrackerCoreData in
            let entity = TrackerCoreData(context: context)
            entity.id = tracker.id
            entity.name = tracker.name
            entity.color = tracker.color
            entity.emoji = tracker.emoji
            entity.schedule = tracker.schedule
                .map { String($0.rawValue) }
                .joined(separator: ",")
            return entity
        }
        
        categoryEntity.addToTrackers(NSSet(array: trackerEntities))
        saveContext()
    }
    
    func updateCategory(title: String, with trackers: [Tracker]) {
        guard let categoryEntity = fetchCategoryEntity(with: title) else {
            createCategory(title: title, trackers: trackers)
            return
        }

        let currentTrackers = categoryEntity.trackers as? Set<TrackerCoreData> ?? []

        let newTrackerEntities = trackers.filter { tracker in
            !currentTrackers.contains { $0.id == tracker.id }
        }.map { tracker -> TrackerCoreData in
            let entity = TrackerCoreData(context: context)
            entity.id = tracker.id
            entity.name = tracker.name
            entity.color = tracker.color
            entity.emoji = tracker.emoji
            entity.schedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
            return entity
        }

        categoryEntity.addToTrackers(NSSet(array: newTrackerEntities))
        saveContext()
    }
    
    private func fetchCategoryEntity(with title: String) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        return try? context.fetch(request).first
    }
    
    func deleteCategory(with title: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        do {
            if let category = try context.fetch(request).first {
                context.delete(category)
                saveContext()
            }
        } catch {
            print("❌ Ошибка удаления категории: \(error)")
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            if let object = try context.fetch(request).first {
                context.delete(object)
                saveContext()
            }
        } catch {
            print("❌ Ошибка удаления категории: \(error)")
        }
    }
    
    func renameCategory(_ category: TrackerCategory, newTitle: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            if let object = try context.fetch(request).first {
                object.title = newTitle
                saveContext()
            }
        } catch {
            print("❌ Ошибка переименования категории: \(error)")
        }
    }
    
    // MARK: - Fetch
    func getAllCategories() -> [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { convertToCategory(from: $0) }
    }
    
    // MARK: - Helpers
    private func convertToCategory(from entity: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = entity.title else { return nil }
        let trackers = (entity.trackers as? Set<TrackerCoreData>)?.compactMap {
            TrackerStore.convertToTracker(from: $0)
        } ?? []
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func saveContext() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("❌ Ошибка сохранения категорий: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}

