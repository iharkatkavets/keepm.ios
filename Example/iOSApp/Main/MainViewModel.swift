//
//  MainViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import RxSwift
import Foundation

protocol MainViewModelInput {
    var didTriggerViewDidAppear: PublishSubject<Void> { get }
}

class MainViewModel: MainViewModelInput {
    enum FileFromPreviousSession {
        case notExists
        case exists(at: URL)
    }

    public let disposeBag = DisposeBag()
    let userSettings: UserSettingsInterface
    let didTriggerViewDidAppear: PublishSubject<Void> = PublishSubject()
    var router: MainRouterInput!

    init(withUser settings: UserSettingsInterface) {
        self.userSettings = settings

        self.didTriggerViewDidAppear
            .map { self.getFileFromPreviousSession() }
            .map { self.navigateNextScreen(with: $0) }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func getFileFromPreviousSession() -> FileFromPreviousSession {
        if let url = self.userSettings.lastUsedFilePath,
            FileManager.default.fileExists(atPath: url.path) == true {
            return .exists(at: url)
        }

        return .notExists
    }

    func navigateNextScreen(with fileResult: FileFromPreviousSession) {
        if case .notExists = fileResult {
            self.router.openFilesList()
        } else {
            self.router.openFilesList()
        }
    }
}
