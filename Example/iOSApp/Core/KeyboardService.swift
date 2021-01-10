//
//  KeyboardService.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift

protocol KeyboardServiceInput {
    var keyboardHeightObservable: Observable<CGFloat> { get }
}

class KeyboardService: KeyboardServiceInput {
    var keyboardHeightSubject = BehaviorSubject<CGFloat>(value: 0)
    var keyboardHeightObservable: Observable<CGFloat> {
        return keyboardHeightSubject.asObserver()
    }

    func start() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillBeShown(note: Notification) {
        let userInfo = note.userInfo
        let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        keyboardHeightSubject.onNext(keyboardFrame.height)
    }

    @objc func keyboardWillBeHidden(note: Notification) {
        keyboardHeightSubject.onNext(0)

    }
}
