//
//  AppSettingsCellViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 3/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AppSettingsCellViewModel {
    var title: String = "Enable touch id"
    var switchIsHidden: Bool = false
    var switchIsOn: Bool = false
    var switchToggled: ((Bool) -> Void)?
    
    func bindSwitchToggleObservable(_ observable: Observable<Bool>, disposeBag: DisposeBag) {
        observable
            .do(onNext: { [weak self] in
                self?.switchToggled?($0)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

class AppSettingsModel {
    var title: String?
    var boolValue: Bool?
    var boolValueChangedHandler: ((Bool) -> Void)?
    
}
