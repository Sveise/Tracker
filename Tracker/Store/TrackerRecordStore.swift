//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Svetlana Varenova on 07.10.2025.
//

import CoreData
import UIKit

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Init
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("Unable to access AppDelegate")
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
    
    // MARK: - Setup FRC
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
            print("❌ Ошибка FRC (TrackerRecord): \(error)")
        }
    }
    
    // MARK: - CRUD
    func addRecord(_ record: TrackerRecord) {
        let recordEntity = TrackerRecordCoreData(context: context)
        recordEntity.id = UUID()
        recordEntity.trackerId = record.trackerId
        recordEntity.date = record.date
        saveContext()
    }
    
    func deleteRecord(trackerId: UUID, date: Date) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
        
        do {
            if let record = try context.fetch(request).first {
                context.delete(record)
                saveContext()
            }
        } catch {
            print("❌ Ошибка удаления записи: \(error)")
        }
    }
    
    // MARK: - Fetch
    func getAllRecords() -> [TrackerRecord] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { convertToRecord(from: $0) }
    }
    
    // MARK: - Helpers
    private func convertToRecord(from entity: TrackerRecordCoreData) -> TrackerRecord? {
        guard let id = entity.trackerId, let date = entity.date else { return nil }
        return TrackerRecord(trackerId: id, date: date)
    }
    
    private func saveContext() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("❌ Ошибка сохранения записи: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}
