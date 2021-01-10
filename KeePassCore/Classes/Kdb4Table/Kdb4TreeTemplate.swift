//
//  Kdb4TemplateBuilder.swift
//  KeePassCore
//
//  Created by igork on 1/28/20.
//

import Foundation

public struct Kdb4TreeTemplate {
    static public func create() -> Kdb.Tree {
        let now = Date()
        let tree = Kdb.Tree()
        tree.generator = KDB_GENERATOR
        tree.databaseName = ""
        tree.databaseNameChanged = now
        tree.databaseDescription = nil
        tree.databaseDescriptionChanged = now
        tree.defaultUserName = ""
        tree.defaultUserNameChanged = now
        tree.maintainanceHistoryDays = 365
        tree.color = nil
        tree.masterKeyChanged = now
        tree.masterKeyChangeRec = -1
        tree.masterKeyChangeForce = -1
        tree.memoryProtection.protectTitle = false
        tree.memoryProtection.protectUserName = false
        tree.memoryProtection.protectPassword = true
        tree.memoryProtection.protectURL = false
        tree.memoryProtection.protectNotes = false
        tree.recycleBinEnabled = true
        tree.recycleBinUUID = nil
        tree.recycleBinChanged = now
        tree.entryTemplatesGroup = UUID.zero
        tree.entryTemplatesGroupChanged = now
        tree.historyMaxItems = 10
        tree.historyMaxSize = 65300
        tree.lastSelectedGroup = UUID.zero
        tree.lastTopVisibleGroup = UUID.zero
        tree.binaries = nil
        tree.customData = nil

        let group = Kdb.Group(name: "Root")
        tree.group = group

        return tree
    }
}
