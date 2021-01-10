//
//  DispatchOnce.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public final class DispatchOnce {
    private var lock = os_unfair_lock()
    private var isPerformed = false
    public func perform(block: () -> Void) {
        os_unfair_lock_lock(&lock)
        if !isPerformed {
            block()
            isPerformed = true
        }
        os_unfair_lock_unlock(&lock)
    }
}
