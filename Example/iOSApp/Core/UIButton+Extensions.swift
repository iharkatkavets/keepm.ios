//
//  UIButton+Extensions.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/15/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIButton {
    func startRotation(_ rps: CFTimeInterval = 1) {
        guard layer.animation(forKey: "rotateAnimation") == nil else {
            return
        }

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = 2*CGFloat.pi
        animation.duration = rps
        animation.repeatCount = Float.greatestFiniteMagnitude
        layer.add(animation, forKey: "rotateAnimation")
    }

    func stopRotation() {
        layer.removeAnimation(forKey: "rotateAnimation")
    }

    var isRotating: Bool {
        return layer.animation(forKey: "rotateAnimation") != nil
    }
}
