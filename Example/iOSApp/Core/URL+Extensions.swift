//
//  URL+Extensions.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 7/20/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

extension URL {
    public func pathWithDeletingDocumentsDir() -> String {
        if let documentsDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path,
            path.hasPrefix(documentsDirPath) {
            return String(path.dropFirst(documentsDirPath.count))
        }
        else {
            return self.path
        }
    }
}
