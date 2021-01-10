//
//  DocumentsManager.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift

protocol AppStorageInput {
    func contentOfDirectory(_ url: URL) -> [StorageItem]
    func remove(_ document: StorageItem)
    static var documentsDir: StorageItem { get }
}

enum AppStorageError: Error {
    case readDirectoryIssue
}

struct StorageItem: Equatable {
    let name: String
    let path: String
    let isDirectory: Bool
    let url: URL

    init(url: URL, isDirectory: Bool = false) {
        self.url = url
        self.isDirectory = isDirectory
        self.name = url.lastPathComponent
        self.path = url.path
    }
}

class AppStorage: AppStorageInput {
    let directory: StorageItem
    let localFileManager = FileManager.default

    static var documentsDir: StorageItem {
        let fileManager = FileManager.default
        if let documentsDirUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let directory = StorageItem(url: documentsDirUrl, isDirectory: true)
            return directory
        }
        fatalError("Can't locate documents directory")
    }

    init(directory: StorageItem) {
        self.directory = directory
    }

    func contentOfDirectory(_ url: URL) -> [StorageItem] {
        let resourceKeys = [URLResourceKey.nameKey,
                            URLResourceKey.isDirectoryKey,
                            URLResourceKey.pathKey,
                            URLResourceKey.contentModificationDateKey]
        var result: [StorageItem] = []

        guard let directoryEnumerator =
                self.localFileManager.enumerator(at: url,
                                                 includingPropertiesForKeys: resourceKeys,
                                                 options: [.skipsHiddenFiles]) else {
            return []
        }

        for case let fileURL as NSURL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                let isDirectory = resourceValues[URLResourceKey.isDirectoryKey] as? Bool else {
                    continue
            }

            let directory = StorageItem(url: fileURL as URL, isDirectory: isDirectory)
            result.append(directory)
            if isDirectory {
                directoryEnumerator.skipDescendants()
            }
        }

        return result
    }

    func remove(_ document: StorageItem) {
        let url = URL(fileURLWithPath: document.path)
        let localFileManager = FileManager.default
        do {
            try localFileManager.removeItem(at: url)
        }
        catch {
        }

    }
}

