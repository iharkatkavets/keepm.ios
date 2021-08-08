//
//  MetadataStore.swift
//  iOSApp
//
//  Created by igork on 15.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreData
import Foundation

struct CreateGoogleDriveParameters {
    let type: Int16
    let version: Int64
    let absoletePath: String
    let modifyDate: String
}

enum MetadataStoreError: Error {
    case wrongData
}

protocol MetadataStoreInput {

}

class MetadataStore: MetadataStoreInput {
    class DocumentsDirectoryContainer: NSPersistentContainer {
        override class func defaultDirectoryURL() -> URL {
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)

            if let url = urls.first {
                return url
            } else {
                return super.defaultDirectoryURL()
            }
        }
    }

    fileprivate lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true


        let container = DocumentsDirectoryContainer(name: "MetadataStore")
        //        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    init() {
    }

    private func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }

    func createGoogleDriveFileMetadata(_ params: CreateGoogleDriveParameters,
                                       _ completion: @escaping (GoogleDriveFileMetadata) -> Void) throws {
        let ctx = persistentContainer.newBackgroundContext()
        ctx.perform {

            let bfmmo = NSEntityDescription.insertNewObject(forEntityName: "CDBaseFileMetadata", into: ctx)
            bfmmo.setValue(params.type, forKey: "type")
            bfmmo.setValue(params.version, forKey: "version")
//            bfmmo.p


            let gdfmmo = NSEntityDescription.insertNewObject(forEntityName: "CDGoogleDriveFileMetadata",
                                                             into: ctx)
            gdfmmo.setValue(bfmmo, forKey: "base")
//            return GoogleDriveFileMetadata(fileId: "", syncDate: Date(), fileVersion: 0, relativePath: "")

            completion(GoogleDriveFileMetadata(fileId: "", syncDate: Date(), fileVersion: 0, relativePath: ""))
        }
    }
}

fileprivate extension String {
    static var uuid: String {
        return UUID().uuidString
    }
}
