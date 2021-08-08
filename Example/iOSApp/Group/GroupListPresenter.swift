//
//  TreeViewModel.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 11/25/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import KeePassCore
import os.log

struct SectionOfGroupItems: Hashable {
    var header: String
    var items: [CellViewModel]

    func hash(into hasher: inout Hasher) {
        hasher.combine(header)
    }

    static func == (lhs: SectionOfGroupItems, rhs: SectionOfGroupItems) -> Bool {
        guard lhs.header == rhs.header else {
            return false
        }

        return true
    }
}

enum CellViewModel {
    case group(GroupCellViewModel)
    case entry(EntryCellViewModel)
}

extension CellViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .group(let value):
            return hasher.combine(value)
        case .entry(let value):
            return hasher.combine(value)
        }
    }

    static func ==(lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        switch (lhs, rhs) {
        case (.group(let lhsValue), .group(let rhsValue)):
            return lhsValue == rhsValue
        case (.entry(let lhsValue), .entry(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

struct GroupCellViewModel: Hashable {
    let group: Kdb.Group

    var name: String? {
        return group.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: GroupCellViewModel, rhs: GroupCellViewModel) -> Bool {
        return lhs.group.uuid == rhs.group.uuid
    }
}

struct EntryCellViewModel: Hashable {
    let entry: Kdb.Entry

    var title: String? {
        return entry.strings.first { $0.key == "Title" }?.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: EntryCellViewModel, rhs: EntryCellViewModel) -> Bool {
        return lhs.entry.uuid == rhs.entry.uuid
    }
}

protocol GroupViewOutput {
    func loadData()
    func select(_ model: CellViewModel)
    func delete(_ model: CellViewModel)
}

class GroupListPresenter {
    weak var view: GroupListViewInput?
    let kdbGroup: Kdb.Group
    var router: GroupListRouter!
    let servicesPool: ServicesPoolInput
    var screenTitle: String? {
        return kdbGroup.name
    }
    let outLog = OSLog(subsystem: "com.katkavets.kdbxapp", category: "GroupCellViewModel")
    let refreshCallback: () -> Void
    private var entriesCellsViewModels = [CellViewModel]()
    private var groupsCellsViewModels = [CellViewModel]()
    var sections = [SectionOfGroupItems]()
    private(set) var noDataHidden: Bool = false

    init(kdbGroup: Kdb.Group, servicesPool: ServicesPoolInput, refreshCallback: @escaping () -> Void) {
        self.kdbGroup = kdbGroup
        self.servicesPool = servicesPool
        self.refreshCallback = refreshCallback
    }

    func loadData() {
        self.reloadDisplayData()
    }

    func selectGroup(viewModel: GroupCellViewModel) {
        let name = viewModel.name ?? ""
        router.openGroup(viewModel.group, title: name) {
            
        }
    }

    func selectEntry(viewModel: EntryCellViewModel) {
        let name = viewModel.title ?? ""
        router.openEntry(viewModel.entry, title: name) {
            self.reloadDisplayData()
        }
    }

    func deleteGroup(viewModel: GroupCellViewModel) {
        guard let kdbService = self.servicesPool.kdbServiceAdapter else {
            return
        }

        kdbGroup.remove(viewModel.group)
        do {
            try kdbService.save()
            self.reloadDisplayData()
        } catch {
            os_log(.error, log: self.outLog, "can't save changes %{public}@", error as NSError)
        }
    }

    func deleteEntry(viewModel: EntryCellViewModel) {
        guard let kdbService = self.servicesPool.kdbServiceAdapter else {
            return
        }

        if kdbGroup.remove(viewModel.entry) == true {
            do {
                try kdbService.save()
                self.reloadDisplayData()
            } catch {
                os_log(.error, log: self.outLog, "can't save changes %{public}@", error as NSError)
            }
        }

    }

    func didSelectAdd() {
        router.showAddActions([.addGroup,.addEntry]) { action in
            if case .addGroup = action {
                os_log(.info, log: self.outLog, "addGroup")
                self.addGroup()
            }
            else if case .addEntry = action {
                os_log(.info, log: self.outLog, "addEntry")
                self.addEntry()
            }
        }
    }

    func addGroup() {
        router.presentScreenToEnterTitle { (newTitle) in
            os_log(.info, log: self.outLog, "entered new title %s", newTitle)
            _ = self.kdbGroup.addNewGroup(name: newTitle)

            guard let kdbService = self.servicesPool.kdbServiceAdapter else {
                return
            }

            do {
                try kdbService.save()
                self.reloadDisplayData()
            } catch {
                os_log(.error, log: self.outLog, "can't save changes %{public}@", error as NSError)
            }
        }
    }

    func addEntry() {
        router.openAddEntryToGroup(self.kdbGroup) {
            self.reloadDisplayData()
        }
    }

    func deleteElement() {

    }

    func reloadDisplayData() {
        groupsCellsViewModels = kdbGroup.groups
            .map { return CellViewModel.group(GroupCellViewModel(group: $0)) }

        entriesCellsViewModels = kdbGroup.entries
            .map { return CellViewModel.entry(EntryCellViewModel(entry: $0)) }

        noDataHidden = (groupsCellsViewModels.count > 0 || entriesCellsViewModels.count > 0)

        var result = [SectionOfGroupItems]()
        if groupsCellsViewModels.count > 0 {
            let groupSection = SectionOfGroupItems(header: "Groups", items: groupsCellsViewModels)
            result.append(groupSection)
        }

        if entriesCellsViewModels.count > 0 {
            let entriesSection = SectionOfGroupItems(header: "Entries", items: entriesCellsViewModels)
            result.append(entriesSection)
        }

        sections = result
        view?.display(sections)
    }

    func closeFile() {
        self.servicesPool.closeKdbFile()
        self.router.close {
            self.refreshCallback()
        }
    }

    func select(_ model: CellViewModel) {
        if case .group(let value) = model {
            selectGroup(viewModel: value)
        } else if case .entry(let value) = model {
            selectEntry(viewModel: value)
        }
    }

    func delete(_ model: CellViewModel) {
        if case .group(let value) = model {
            deleteGroup(viewModel: value)
        } else if case .entry(let value) = model {
            deleteEntry(viewModel: value)
        }
    }
}
