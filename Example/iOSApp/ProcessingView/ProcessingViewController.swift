//
//  ProcessingViewController.swift
//  iOSApp
//
//  Created by igork on 2/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

protocol ProcessingViewInput: class {
    func getViewController() -> ProcessingViewController
}

class ProcessingViewController: UIViewController, ProcessingViewInput, PopupPresentable {
    weak var popupViewController: PopupViewController?
    let resolver: Swinject.Resolver
    let viewModel: ProcessingViewModel
    let disposeBag = DisposeBag()

    init(withViewModel model: ProcessingViewModel,
         resolver: Resolver) {
        self.viewModel = model
        self.resolver = resolver
        super.init(nibName: "ProcessingViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func getViewController() -> ProcessingViewController {
        return self
    }
}
