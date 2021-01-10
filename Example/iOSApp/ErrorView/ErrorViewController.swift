//
//  ErrorViewController.swift
//  iOSApp
//
//  Created by igork on 2/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

protocol ErrorViewInput {
    func getViewController() -> ErrorViewController
}

class ErrorViewController: UIViewController, ErrorViewInput, PopupPresentable {
    weak var popupViewController: PopupViewController?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!

    var errorTitle: String?
    var errorMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = errorTitle
        messageLabel.text = errorMessage
    }

    func getViewController() -> ErrorViewController {
        self
    }

    @IBAction func okDidTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
