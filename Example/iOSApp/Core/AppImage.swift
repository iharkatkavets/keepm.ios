//
//  AppImage.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/15/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

enum AppImage {
    case sync_warn
    case kdbfile
    case question
    case sync
    case info

    var image: UIImage {
        switch self {
        case .sync_warn: return #imageLiteral(resourceName: "ic-sync-warning")
        case .kdbfile: return #imageLiteral(resourceName: "ic-keys")
        case .question: return #imageLiteral(resourceName: "question")
        case .sync: return #imageLiteral(resourceName: "bt-sync")
        case .info: return #imageLiteral(resourceName: "info")
        }
    }
}

extension UIButton {
    func setImage(_ image: AppImage, for state: UIControl.State) {
        setImage(image.image, for: state)
    }
}
