//
//  TrackerStore.swift
//  Tracker
//
//  Created by Svetlana Varenova on 07.10.2025.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Init
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("Unable ro access AppDelegate")
            self.init(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
            return
        }
        let context = appDelegate.coreDataStack.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - FetchedResultsController Setup
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        frc.delegate = self
        self.fetchedResultsController = frc
        
        do {
            try frc.performFetch()
        } catch {
            print("❌ Ошибка загрузки трекеров через FRC: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func getAllTrackers() -> [Tracker] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { TrackerStore.convertToTracker(from: $0) }
    }
    
    func createTracker(from tracker: Tracker) {
        _ = createTrackerEntity(from: tracker)
        saveContext()
    }
    
    func deleteTracker(with id: UUID) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let trackerToDelete = try context.fetch(request).first {
                context.delete(trackerToDelete)
                saveContext()
            }
        } catch {
            print("❌ Ошибка удаления трекера: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    private func createTrackerEntity(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        configure(trackerCoreData, with: tracker)
        return trackerCoreData
    }
    
    private func configure(_ entity: TrackerCoreData, with tracker: Tracker) {
        entity.id = tracker.id
        entity.name = tracker.name
        entity.color = tracker.color
        entity.emoji = tracker.emoji
        entity.schedule = tracker.schedule
            .map { String($0.rawValue) }
            .joined(separator: ",")
        entity.isPinned = tracker.isPinned
    }
    
    private func saveContext() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("❌ Ошибка сохранения контекста: \(error)")
        }
    }
    
    static func convertToTracker(from entity: TrackerCoreData) -> Tracker? {
        guard
            let id = entity.id,
            let name = entity.name,
            let color = entity.color,
            let emoji = entity.emoji
        else { return nil }
        
        let weekDays: [WeekDay] = entity.schedule?
            .split(separator: ",")
            .compactMap { Int($0) }
            .compactMap { WeekDay(rawValue: $0) } ?? []
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: weekDays,
            isPinned: entity.isPinned
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}

// MARK: - Update Tracker
extension TrackerStore {
    func updateTracker(_ tracker: Tracker) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.name = tracker.name
                entity.color = tracker.color
                entity.emoji = tracker.emoji
                entity.schedule = tracker.schedule
                    .map { String($0.rawValue) }
                    .joined(separator: ",")
                entity.isPinned = tracker.isPinned
                try context.save()
                delegate?.didUpdateTrackers()
            }
        } catch {
            print("❌ Ошибка обновления трекера: \(error)")
        }
    }
}

extension TrackerStore {
    func togglePin(for tracker: Tracker) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.isPinned = !(entity.isPinned)
            } else {
                print("⚠️ Трекер не найден для togglePin")
            }
            try context.save()
            delegate?.didUpdateTrackers()
        } catch {
            print("❌ Ошибка togglePin: \(error)")
        }
    }
}
