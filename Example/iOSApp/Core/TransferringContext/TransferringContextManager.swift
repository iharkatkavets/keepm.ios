//
//  TransferringContextManager.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class TransferringContext: NSObject, Identifiable {
    var progress: Float = 0.0
    var processing: Bool = false
    let url: URL
//    let identifier: String = ""

    init(url: URL) {
        self.url = url
    }
}

protocol TransferringContextManagerInput: class {
    func createContentForURL(_ url: URL) -> TransferringContext
    func removeContext(_ context: TransferringContext)
    func fetchContextFor(_ url: URL) -> TransferringContext?
}

struct TransferringContextNotification {
    static let transferringPoolDidChange: NSNotification.Name = NSNotification.Name(rawValue: "TransferringPoolDidChange")
}

class TransferringContextManager: TransferringContextManagerInput {
    var poolMap = [URL: TransferringContext]()
    let notificationCenter = NotificationCenter.default

    func createContentForURL(_ url: URL) -> TransferringContext {
        if let existingContext = poolMap[url] {
            return existingContext
        }

        let context = TransferringContext(url: url)

        poolMap[url] = context
        notificationCenter.post(name: TransferringContextNotification.transferringPoolDidChange, object: self)
        return context
    }

    func fetchContextFor(_ url: URL) -> TransferringContext? {
        return poolMap[url]
    }

    func removeContext(_ context: TransferringContext) {
        let url = context.url

        guard poolMap[url] != nil else {
            return
        }

        poolMap[url] = nil
        notificationCenter.post(name: TransferringContextNotification.transferringPoolDidChange, object: self)
    }
}
