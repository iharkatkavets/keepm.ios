//
//  Once.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class Once {
    var didRun: Bool = false

    func run(block: () -> Void) {
        guard !didRun else { return }

        block()
        didRun = true
    }
}
