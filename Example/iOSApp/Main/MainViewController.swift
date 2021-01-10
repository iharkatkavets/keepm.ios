//
//  MainViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/9/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol MainViewInput: class {
    func getViewController() -> UIViewController
}

class MainViewController: UIViewController {
    let viewModel: MainViewModelInput

    required init(withModel viewModel: MainViewModelInput) {
        self.viewModel = viewModel
        super.init(nibName: "MainViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.didTriggerViewDidAppear.onNext(())
    }
}

extension MainViewController: MainViewInput {
    func getViewController() -> UIViewController {
        return self
    }
}
