//
//  GoogleDriveViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol GoogleDriveViewInput: class {
    func getViewController() -> UIViewController
}

class GoogleDriveViewController: UIViewController, GoogleDriveViewInput, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private var signInButton: UIButton!
    let viewModel: GoogleDriveViewModel
    let disposeBag = DisposeBag()
    let fileCellDecorator = FileDecorator()
    let folderCellDecorator = FolderDecorator()

    @IBOutlet var tableView: UITableView!
    var documents = [GoogleDriveItem]()
    @IBOutlet private var loadingIdicator: UIActivityIndicatorView!
    let refreshControl = UIRefreshControl()
    
    init(viewModel: GoogleDriveViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "GoogleDriveViewController", bundle: nil)
        self.title = viewModel.screenTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableDataSource()
        viewModel.signInButtonHiddenObservable.bind(to: signInButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.loadingIndicatorHiddenObservable.bind(to: loadingIdicator.rx.isHidden).disposed(by: disposeBag)

        let settingsButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "bt-google-drive-settings"), style: .plain, target: self, action: #selector(didSelectSettings(_:)))
        let exitItem = UIBarButtonItem(image: #imageLiteral(resourceName: "bt-exit"), style: .plain, target: self, action: #selector(didSelectExit(_:)))
        self.navigationItem.rightBarButtonItems = [exitItem,settingsButtonItem]
    }

    @IBAction func didSelectSettings(_ button: UIBarButtonItem) {
        viewModel.showSettings(from: button)
    }

    @IBAction func didSelectExit(_ button: UIBarButtonItem) {
        viewModel.exit(disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didTriggerViewDidAppear(self, disposeBag: disposeBag)

    }
    
    func getViewController() -> UIViewController {
        return self
    }
    
    @IBAction func signIn(_ button: UIButton) {
        viewModel.signIn(self, disposeBag: disposeBag)
    }
    
    func configureTableDataSource() {
        tableView.register(UINib(nibName: "GoogleDriveDocumentCell", bundle: nil),
                           forCellReuseIdentifier: "GoogleDriveDocumentCell")
        tableView.tableFooterView = UIView()
        viewModel.directoryContentObservable
            .do(onNext: { [weak self] in
                self?.documents = $0
                self?.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
            })
            .subscribe().disposed(by: disposeBag)


        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: .valueChanged)
        viewModel.refreshIndicatorIsAnimatingObservable.bind(to: refreshControl.rx.isRefreshing).disposed(by: disposeBag)
    }

    @objc func refreshList(_ control: UIRefreshControl) {
        viewModel.forceRefreshData(disposeBag: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleDriveDocumentCell", for: indexPath)
        if let fileCell = cell as? GoogleDriveDocumentCell {
            let cellViewModel = self.documents[indexPath.row]
            if cellViewModel.isDirectory {
                fileCell.decorate(with: self.folderCellDecorator)
            }
            else {
                fileCell.decorate(with: self.fileCellDecorator)
            }
            fileCell.viewModel = self.documents[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let document = self.documents[indexPath.row]
        viewModel.userDidSelectDocument(document, disposeBag: disposeBag)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



