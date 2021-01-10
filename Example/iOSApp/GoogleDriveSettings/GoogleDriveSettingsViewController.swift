//
//  GoogleDriveSettingsViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol GoogleDriveSettingsViewInput {
    func getViewController() -> UIViewController
}

class GoogleDriveSettingsViewController: UIViewController, GoogleDriveSettingsViewInput {
    @IBOutlet var showOnlyKDBFilesSwitch: UISwitch!
    let servicesPool: ServicesPoolInput
    let disposeBag = DisposeBag()

    init(servicesPool: ServicesPoolInput) {
        self.servicesPool = servicesPool
        super.init(nibName: "GoogleDriveSettingsViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let isOn = self.servicesPool.appSettingsService?.bool(forKey: .showOnlyKDBFiles) ?? true
        showOnlyKDBFilesSwitch.setOn(isOn, animated: false)
        showOnlyKDBFilesSwitch.addTarget(self, action: #selector(didToggleShowOnlyKDBFileSwitch(_:)), for: .valueChanged)
    }

    func getViewController() -> UIViewController {
        return self
    }

    @objc func didToggleShowOnlyKDBFileSwitch(_ control: UISwitch) {
        self.servicesPool.appSettingsService?.set(control.isOn, forKey: .showOnlyKDBFiles)
    }

}
