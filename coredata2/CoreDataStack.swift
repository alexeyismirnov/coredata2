//
//  CoreDataStack.swift
//  coredata_populate
//
//  Created by Alexey Smirnov on 3/5/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "coredata2")
        
        let description = container.persistentStoreDescriptions.first
        /*
        description?.setOption(true as NSNumber,
                               forKey: NSPersistentHistoryTrackingKey)
 */
        
        description?.setOption(true as NSNumber,
                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description?.setOption(true as NSNumber,
                               forKey: remoteChangeKey)
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
   
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


