//
//  UIScrollView+Extensions.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/13/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIScrollView {
    var rightOffsetX: CGFloat {
        return contentOffset.x+contentSize.width
    }
}
