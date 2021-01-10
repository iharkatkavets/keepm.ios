//
//  PopupPresentable.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit



protocol PopupPresentable where Self: UIViewController {
    var popupViewController: PopupViewController? { get set }
}
