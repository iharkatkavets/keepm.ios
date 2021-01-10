//
//  AppSettingsViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa
import Swinject
import Foundation

protocol AppSettingsViewInput: class {
    func getViewController() -> UIViewController
}

class AppSettingsViewController: UIViewController, AppSettingsViewInput {
    let resolver: Swinject.Resolver
    let viewModel: AppSettingsViewModel
    let disposeBag = DisposeBag()
    let once = DispatchOnce()
    @IBOutlet private var tableView: UITableView!

    init(withViewModel model: AppSettingsViewModel,
         resolver: Resolver) {
        self.viewModel = model
        self.resolver = resolver
        super.init(nibName: "AppSettingsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "AppSettingsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AppSettingsCell")

        tableView.tableFooterView = UIView()
    }

    func getViewController() -> UIViewController {
        return self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        once.perform {
            viewModel.cellViewModels().bind(to: tableView.rx.items(cellIdentifier: "AppSettingsCell", cellType: AppSettingsCell.self)) { (row, element, cell) in
                cell.viewModel = element

            }
            .disposed(by: disposeBag)
        }

    }
}
