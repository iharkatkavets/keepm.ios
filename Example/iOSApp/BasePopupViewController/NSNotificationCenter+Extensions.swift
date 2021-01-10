//
//  NSNotificationCenter+Extensions.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct NotificationDescriptor<Payload> {
    let name: Notification.Name
    let convert: (Notification) -> Payload
}

extension NotificationCenter {
    func addObserver<Payload>(with descriptor: NotificationDescriptor<Payload>, block: @escaping (Payload) -> ()) -> NSObjectProtocol {
        return addObserver(forName: descriptor.name, object: nil, queue: nil) { (note) in
            block(descriptor.convert(note))
        }
    }

    
}
