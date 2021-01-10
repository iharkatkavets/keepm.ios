//
//  Colors.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

enum AppColors: String {
    case primary
    case secondary
    case error
    case placeholder
    case shadow
    case label
    case selected
    case popover

    var color: UIColor {
        return UIColor(named: self.rawValue)!
    }

    static subscript(index: Self) -> UIColor {
        get {
            return UIColor(named: index.rawValue)!
        }
    }
}
