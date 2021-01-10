//
//  DownloadingViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

protocol DownloadingViewInput: class {
    func getViewController() -> UIViewController
}

class DownloadingViewController: UIViewController, DownloadingViewInput {
    let resolver: Swinject.Resolver
    let viewModel: DownloadingViewModel
    let disposeBag = DisposeBag()

    init(withViewModel model: DownloadingViewModel,
         resolver: Resolver) {
        self.viewModel = model
        self.resolver = resolver
        super.init(nibName: "DownloadingViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func getViewController() -> UIViewController {
        return self
    }
}
