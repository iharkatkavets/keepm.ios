//
//  GoogleDriveViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/3/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import GoogleAPIClientForREST
import os.log

class GoogleDriveViewModel {
    let servicesPool: ServicesPoolInput
    private let directoryContentVariable = BehaviorRelay<[GoogleDriveItem]>(value: [])
    var directoryContentObservable: Observable<[GoogleDriveItem]> {
        return directoryContentVariable.asObservable()
    }
    var currentList: [GoogleDriveItem]?
    let rootDirectory: GoogleDriveItem?
    var router: GoogleDriveRouter!
    var screenTitle: String {
        if let title = rootDirectory?.name {
            return title
        }
        else {
            return "Google Drive"
        }
    }
    let fileManager = FileManager.default
    let outLog = OSLog(subsystem: "com.katkavets.kdbxapp", category: "GoogleDriveViewModel")
    let once = DispatchOnce()
    private let signInButtonHiddenVariable = BehaviorRelay<Bool>(value: true)
    var signInButtonHiddenObservable: Observable<Bool> {
        return signInButtonHiddenVariable.asObservable()
    }
    private let loadingIndicatorHiddenVariable = BehaviorRelay<Bool>(value: true)
    var loadingIndicatorHiddenObservable: Observable<Bool> {
        return loadingIndicatorHiddenVariable.asObservable()
    }

    private let refreshIndicatorIsAnimatingVariable = BehaviorRelay<Bool>(value: false)
    var refreshIndicatorIsAnimatingObservable: Observable<Bool> {
        return refreshIndicatorIsAnimatingVariable.asObservable()
    }
    
    init(servicesPool: ServicesPoolInput, rootDirectory: GoogleDriveItem? = nil) {
        self.servicesPool = servicesPool
        self.rootDirectory = rootDirectory
    }
    
    func signIn(_ viewController: UIViewController, disposeBag: DisposeBag) {
        guard let googleDriveService = servicesPool.googleDriveService else {
            return
        }

        self.loadingIndicatorHiddenVariable.accept(false)
        self.signInButtonHiddenVariable.accept(true)
        googleDriveService.signInUsingViewController(viewController) { (result) in
            if case .success = result {
                self.fetchFiles()
            }
            else if case .failure(let error) = result {
                self.loadingIndicatorHiddenVariable.accept(true)
                self.signInButtonHiddenVariable.accept(false)
            }
        }
    }
    
    func didTriggerViewDidAppear(_ viewController: UIViewController, disposeBag: DisposeBag) {
        guard let googleDriveService = servicesPool.googleDriveService else {
            return
        }

        once.perform {
            if googleDriveService.isSignedIn {
                self.loadingIndicatorHiddenVariable.accept(false)
                self.fetchFiles()
            }
            else if googleDriveService.canSignInSilent() {
                self.loadingIndicatorHiddenVariable.accept(false)
                googleDriveService.signInSilent { (result) in
                    if case .success = result {
                        self.fetchFiles()
                    }
                    else if case .failure = result {
                        self.loadingIndicatorHiddenVariable.accept(true)
                        self.signInButtonHiddenVariable.accept(false)
                    }
                }
            }
            else {
                signInButtonHiddenVariable.accept(false)
            }
        }
    }

    func presentError(_ error: GoogleDriveServiceError) {
        switch error {
        case .signInError:
            self.router.presentError("Can't Sign In to Google Drive", message: "")
        default:
            self.router.presentError("Internal error", message: "")
        }
    }
    
    fileprivate func fetchFiles() {
        guard let googleDriveService = servicesPool.googleDriveService else {
            return
        }

        return googleDriveService.fetchDirectory(rootDirectory?.model) { (result) in
            if case .success(let list) = result {
                self.currentList = list
                let sorted = self.sortContent(list)
                self.directoryContentVariable.accept(sorted)
                self.loadingIndicatorHiddenVariable.accept(true)
                self.refreshIndicatorIsAnimatingVariable.accept(false)
            }
        }
    }
    
    fileprivate func sortContent(_ items: [GoogleDriveItem]) -> [GoogleDriveItem] {
        return items.sorted { lhs,rhs in
            if lhs.isDirectory && !rhs.isDirectory {
                return true
            }
            else if !lhs.isDirectory && rhs.isDirectory {
                return false
            }
            else {
                switch (lhs.name, rhs.name) {
                case (nil, nil): return true
                case (nil, _): return true
                case (_, nil): return false
                case let (l, r): return l!.localizedCaseInsensitiveCompare(r!) == .orderedAscending
                }
            }
        }
    }
    
    func userDidSelectDocument(_ document: GoogleDriveItem, disposeBag: DisposeBag) {
        if document.isDirectory {
            openDirectory(document)
        }
        else if canDownload(document) {
            download(document, disposeBag: disposeBag)
        }
    }

    func download(_ document: GoogleDriveItem, disposeBag: DisposeBag) {
        guard let googleDriveService = servicesPool.googleDriveService else {
            return
        }

        self.router.presentConfirmDownloading(fileName: document.model.name!) { (result) in
            if case .download = result {
                self.router.presentLoadingIndicator { (vc) in
                    googleDriveService.download(document) { (result) in
                        if case .success = result {
                            self.router.dismissLoadingIndicator(vc)
                        }
                        else if case .failure(let error) = result {
                            self.router.dismissLoadingIndicator(vc) {
                                self.handleDownloadingError(error)
                            }
                        }
                    }
                }
            }
        }
    }


    func handleDownloadingError(_ error: Error) {
        if case GoogleDriveDownloadingError.fileExists = error {
            self.router.presentError("File with the same name is already exist. Please remove it to continue")
        }
        else if case MetadataManagerError.versionIssue = error {
            print("it's expired; error = \(error)")
        }
        else {
            print("no match; error = \(error)")
        }
    }

    func canDownload(_ document: GoogleDriveItem) -> Bool {
        return document.isKDBXFile && document.model.name != nil
    }
    
    func openDirectory(_ directory: GoogleDriveItem) {
        router.openDirectory(directory)
    }
    
    func showSettings(from button: UIBarButtonItem) {
        router.showSettings(from: button)
    }

    func exit(_ disposeBag: DisposeBag) {
        guard let googleDriveService = servicesPool.googleDriveService,
            googleDriveService.isSignedIn == true else { return }


        router.presentConfirmSignOut()
            .do(onNext: { [weak self] action in
                if case .confirm = action {
                    self?.directoryContentVariable.accept([])
                    googleDriveService.signOut()
                    self?.signInButtonHiddenVariable.accept(false)
                }
            })
            .subscribe().disposed(by: disposeBag)
    }

    func forceRefreshData(disposeBag: DisposeBag) {
        self.fetchFiles()
    }
}
