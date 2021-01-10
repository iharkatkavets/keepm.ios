//
//  PopupViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

protocol PopupViewInput {
    func getViewController() -> UIViewController
    func setContentViewController(_ controller: PopupPresentable)
}

class PopupViewController: UIViewController, PopupViewInput {
    func setContentViewController(_ controller: PopupPresentable) {
        if contentViewController !== controller && viewIfLoaded != nil{
            removeContentViewController()
        }

        contentViewController = controller

        if viewIfLoaded != nil {
            addContentViewController()
        }
    }

    @IBOutlet var contentView: UIView!
    @IBOutlet private var safeAreaButton: UIButton!
    @IBOutlet private var safeAreaTopConstraint: NSLayoutConstraint!
    @IBOutlet private var safeAreaBottomConstraint: NSLayoutConstraint!
    @IBOutlet var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var contentViewVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet var contentViewBottomConstraint: NSLayoutConstraint!
    var contentViewController: PopupPresentable?
    var keyboardNotificationObserver1: NSObjectProtocol?
    var keyboardNotificationObserver2: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bounds = UIScreen.main.bounds
        addContentViewController()
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }

    func addContentViewController() {
        if let contentViewController = self.contentViewController {
            addChild(contentViewController)
            contentViewController.view.backgroundColor = UIColor.clear
            contentView.addSubview(contentViewController.view)
            contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                contentViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                contentViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                contentViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            contentViewController.popupViewController = self
            contentViewController.didMove(toParent: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let center = NotificationCenter.default
        keyboardNotificationObserver1 = center.addObserver(with: UIViewController.keyboardWillShow) { [weak self] (payload) in
            self?.keyboardWillShow(payload)
        }
        keyboardNotificationObserver1 = center.addObserver(with: UIViewController.keyboardWillHide) { [weak self] payload in
            self?.keyboardWillHide(payload)
        }
    }

    func keyboardWillShow(_ keyboard: KeyboardParameters) {
        let selfHeight = view.bounds.size.height
        let remainingHeight = selfHeight-safeAreaTopConstraint.constant-safeAreaBottomConstraint.constant-keyboard.endFrame.size.height
        let curveAnimationOptions = UIView.AnimationOptions(rawValue: UInt(keyboard.curve.rawValue << 16))

        let animate: (@escaping () -> Void) -> Void = { block -> Void in
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: keyboard.duration,
                           delay: 0,
                           options: curveAnimationOptions,
                           animations: {
                            block()
                            self.view.layoutIfNeeded()
            })
        }

        if remainingHeight > contentView.bounds.size.height {
            let padding = remainingHeight - contentView.bounds.size.height
            animate {
                self.contentViewTopConstraint.priority = UILayoutPriority.defaultHigh
                self.contentViewTopConstraint.constant = self.safeAreaTopConstraint.constant+padding/2
                self.contentViewBottomConstraint.priority = UILayoutPriority.defaultHigh
                self.contentViewBottomConstraint.constant = self.safeAreaBottomConstraint.constant+keyboard.endFrame.size.height+padding/2
                self.contentViewVerticalCenterConstraint.priority = UILayoutPriority.defaultLow
            }
        }
        else {
            animate {
                self.contentViewTopConstraint.priority = UILayoutPriority.defaultHigh
                self.contentViewTopConstraint.constant = self.safeAreaTopConstraint.constant
                self.contentViewBottomConstraint.priority = UILayoutPriority.defaultHigh
                self.contentViewBottomConstraint.constant = self.safeAreaBottomConstraint.constant+keyboard.endFrame.size.height
                self.contentViewVerticalCenterConstraint.priority = UILayoutPriority.defaultLow
            }
        }
    }

    func keyboardWillHide(_ keyboard: KeyboardParameters) {

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let center = NotificationCenter.default
        center.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: keyboardNotificationObserver1)
        center.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: keyboardNotificationObserver2)
    }

    @IBAction func dismiss(_ button: UIButton) {

    }

    func removeContentViewController() {

    }

    func getViewController() -> UIViewController {
        self
    }
}

extension UIViewController {
    
}
