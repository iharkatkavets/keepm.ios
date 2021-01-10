//
//  KeyboardParameters.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

struct KeyboardParameters {
    let beginFrame: CGRect
    let endFrame: CGRect
    let curve: UIView.AnimationCurve
    let duration: TimeInterval
    let isLocal: Bool

    init(note: Notification) {
        let userInfo = note.userInfo
        beginFrame = userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        endFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        curve = UIView.AnimationCurve(rawValue: userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        isLocal = userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as! Bool
    }
}

extension UIViewController {
    static let keyboardWillShow = NotificationDescriptor(name: UIResponder.keyboardWillShowNotification, convert: KeyboardParameters.init)
    static let keyboardWillHide = NotificationDescriptor(name: UIResponder.keyboardWillHideNotification, convert: KeyboardParameters.init)
}
