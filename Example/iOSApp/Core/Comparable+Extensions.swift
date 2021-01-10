//
//  Comparable+Extensions.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        if self > range.upperBound {
            return range.upperBound
        } else if self < range.lowerBound {
            return range.lowerBound
        } else {
            return self
        }
    }
}
