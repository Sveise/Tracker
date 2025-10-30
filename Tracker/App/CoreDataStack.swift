//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Svetlana Varenova on 07.10.2025.
//

import CoreData

final class CoreDataStack {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Ошибка загрузки хранилища: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let nserror as NSError {
                print("Ошибка сохранения Core Data: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
