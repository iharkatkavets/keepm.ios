//
//  LoadingViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 4/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

//protocol LoadingViewInput {
//
//}

class LoadingViewController: UIViewController, PopupPresentable/*, LoadingViewInput*/ {
    var popupViewController: PopupViewController?
    @IBOutlet private var spinner: SpinnerView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.isAnimating = true
    }
}
