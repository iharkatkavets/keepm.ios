//
//  TreeViewController.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import KeePassCore
import DiffableDataSources

protocol GroupListViewInput: class {
    func getViewController() -> UIViewController
    func setCloseButtonVisible(_ value: Bool)
    func display(_ sections: [SectionOfGroupItems])
}

class GroupListViewController: UIViewController, GroupListViewInput, UITableViewDelegate, UITableViewDataSource {
    let viewOutput: GroupListPresenter
    @IBOutlet var tableView: UITableView!
    var addButton: UIBarButtonItem!
    @IBOutlet var noContentLabel: UILabel!
    let once = DispatchOnce()
    var sections = [SectionOfGroupItems]()

    class GroupListDataSource: TableViewDiffableDataSource<SectionOfGroupItems, CellViewModel> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return snapshot().sectionIdentifiers[section].header
        }

        override func tableView(_ tableView: UITableView, canEditRowAt: IndexPath) -> Bool {
            return true
        }
    }

    private lazy var dataSource = GroupListDataSource(tableView: tableView) { tableView, indexPath, item in
        switch item {
        case .group(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: "KdbGroupTableViewCell", for: indexPath)
            if let groupCell = cell as? KdbGroupTableViewCell {
                groupCell.viewModel = value
            }

            return cell
        case .entry(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: "KdbEntryTableViewCell", for: indexPath)
            if let entryCell = cell as? KdbEntryTableViewCell {
                entryCell.viewModel = value
            }

            return cell
        }
    }

    init(viewModel: GroupListPresenter) {
        self.viewOutput = viewModel
        super.init(nibName: "GroupListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewOutput.screenTitle
        configureTableDataSource()
        configureTopBar()
    }

    func configureTopBar() {
        let moreActionsButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showMoreActions(_:)))
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction(_:)))

        self.navigationItem.rightBarButtonItems = [addButton]
    }

    @objc func showMoreActions(_ sender: UIBarButtonItem) {

    }

    @objc func addAction(_ sender: UIBarButtonItem) {
        viewOutput.didSelectAdd()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        once.perform {
            viewOutput.loadData()
        }
    }

    func configureTableDataSource() {
        tableView.register(UINib(nibName: "KdbGroupTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "KdbGroupTableViewCell")
        tableView.register(UINib(nibName: "KdbEntryTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "KdbEntryTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }

    func tableView(_ tableView: UITableView, canEditRowAt: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.numberOfSections(in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.dataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        viewOutput.select(item)
    }

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let item = self.sections[indexPath.section].items[indexPath.row]
            self.viewOutput.delete(item)
        }

        return [delete]
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, view, completionHandler in
            let item = self.sections[indexPath.section].items[indexPath.row]
            self.viewOutput.delete(item)
            completionHandler(true)
        }

        delete.backgroundColor = UIColor.red

        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    func getViewController() -> UIViewController {
        return self
    }

    func setCloseButtonVisible(_ value: Bool) {
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(didSelectClose(_:)))
        self.navigationItem.leftBarButtonItem = closeButton
    }

    func display(_ newSections: [SectionOfGroupItems]) {
        var snapshot = DiffableDataSourceSnapshot<SectionOfGroupItems, CellViewModel>()
        snapshot.appendSections(newSections)
        newSections.forEach {
            snapshot.appendItems($0.items, toSection: $0)
        }
        dataSource.apply(snapshot, animatingDifferences: true)

        self.sections = newSections

        noContentLabel.isHidden = viewOutput.noDataHidden
    }

    @objc func didSelectClose(_ sender: UIBarButtonItem) {
        viewOutput.closeFile()
    }
}
