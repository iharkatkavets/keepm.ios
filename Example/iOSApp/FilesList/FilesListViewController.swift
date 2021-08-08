//
//  FilesListViewController.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 7/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit


protocol FilesListViewInput: class {
    func getViewController() -> UIViewController
    func displayContentItems(_ items: [StorageDisplayItem])
    func deleteItem(_ item: StorageDisplayItem)
    func displayTitle(_ title: String)
}

protocol FilesListViewOutput: AnyObject {
    func didTriggerViewDidLoad()
    func didTriggerOpenInfo()
    func createFile(viewController: UIViewController)
    func deleteFile(_ displayItem: StorageDisplayItem)
    func refreshContent()
    func openFile(_ displayItem: StorageDisplayItem, viewController: UIViewController)
}


class FilesListViewController: UIViewController, FilesListViewInput, UITableViewDataSource, UITableViewDelegate, FileTableViewCellDelegate {
    @IBOutlet var selectButtonItem: UIBarButtonItem!
    @IBOutlet var cancelButtonItem: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    var output: FilesListViewOutput!
    private lazy var dispatch_once_block = { (do_once: (()->Void)) in
        do_once()
    }
    var documents = [StorageDisplayItem]()
    let servicesPool: ServicesPoolInput
    let refreshControl = UIRefreshControl()
    let transferringContextManager: TransferringContextManagerInput
    
    
    init(servicesPool: ServicesPoolInput,
         transferringContextManager: TransferringContextManagerInput) {
        self.servicesPool = servicesPool
        self.transferringContextManager = transferringContextManager
        super.init(nibName: "FilesListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Device"
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDidTap(_:)))
        self.navigationItem.rightBarButtonItem = addButtonItem
        configureTableDataSource()
        output.didTriggerViewDidLoad()
    }

    @objc func addDidTap(_ sender: UIBarButtonItem) {
        output.createFile(viewController: self)
    }
    
    @IBAction func close(_: UIBarButtonItem) {
        //        router.close()
    }
    
    @IBAction func selectFile(_: UIBarButtonItem) {
        //        router.close()
    }
    
    func getViewController() -> UIViewController {
        return self
    }

    func displayContentItems(_ items: [StorageDisplayItem]) {
        self.refreshControl.endRefreshing()
        self.documents = items
        self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
    }

    func deleteItem(_ item: StorageDisplayItem) {
        for (index, element) in self.documents.enumerated() {
            if element.document == item.document {
                self.documents.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)],
                                          with: .automatic)
            }
        }
    }

    func displayTitle(_ title: String) {
        self.title = title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configureTableDataSource() {
        tableView.register(UINib(nibName: "FileTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "FileTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView()
        
        refreshControl.addTarget(self, action: #selector(userDidPullDownTableView(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func userDidPullDownTableView(_ control: UIRefreshControl) {
        output.refreshContent()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileTableViewCell", for: indexPath)
        if let fileCell = cell as? FileTableViewCell {
            fileCell.setup(model: self.documents[indexPath.row], transferringContextManager: transferringContextManager, viewController: self, delegate: self)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let document = self.documents[indexPath.row]
        self.output.openFile(document, viewController: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            output.deleteFile(self.documents[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.output.deleteFile(self.documents[indexPath.row])
        }
        
        return [delete]
    }

    func didTapShowInfo(_ info: String) {
        output.didTriggerOpenInfo()
    }
}
