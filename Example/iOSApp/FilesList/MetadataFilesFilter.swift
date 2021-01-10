//
//  MetadataFilesFilter.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct MetadataFilesFilter {
    let metaSuffix: String

    init(metaSuffix: String) {
        self.metaSuffix = metaSuffix
    }

    func perform(_ storageItems: [StorageItem]) -> [StorageItem] {
        var result = [StorageItem]()

        let urlItems = storageItems.map { $0.url }

        for item in storageItems {
            let itemURL = item.url
            let hasMetaSuffics = itemURL.lastPathComponent.hasSuffix(metaSuffix)
            if !hasMetaSuffics {
                result.append(item)
                continue;
            }

            let substring = itemURL.absoluteString.dropLast(metaSuffix.lengthOfBytes(using: .utf8))

            if let possibleFileURL = URL(string: String(substring)), urlItems.contains(possibleFileURL) == false {
                result.append(item)
                continue;
            }
        }

        return result
    }
}
