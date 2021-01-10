//
//  XMLWriter.swift
//  KeePassCore
//
//  Created by Igor Kotkovets on 1/9/20.
//

import Foundation

import libxml2
import os.log

class XMLWriter {
    let outputLog = OSLog(subsystem: "KeePassCore", category: "XMLWriter")
    let tree: Kdb.Tree
    let outputStream: OutputStream
    let randomGenerator: RandomGenerator
    lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    lazy var nuberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

    init(tree: Kdb.Tree, outputStream: OutputStream, randomStream: RandomGenerator) {
        self.tree = tree
        self.outputStream = outputStream
        self.randomGenerator = randomStream
    }

    func write() throws {
        let xmlDocument = XMLDocument(rootElement: nil)
        xmlDocument.setRootElement(buildKeePassFile())

        let data = xmlDocument.xmlData
        try data.withUnsafeBytes { (urbp) -> Void in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            _ = try outputStream.write(unsafePointer, maxLength: urbp.count)
        }
    }

    func buildKeePassFile() -> XMLElement {
        let element = xmlElement(name: .KeePassFile)
        element.addChild(buildMeta())
        element.addChild(buildRoot())
        return element
    }

    func buildMeta() -> XMLElement {
        let metaElement = xmlElement(name: .Meta)

        metaElement.addChild(xmlElement(name: .Generator, stringValue: tree.generator))
        metaElement.addChild(xmlElement(name: .HeaderHash, data: tree.headerHash))
        metaElement.addChild(xmlElement(name: .DatabaseName, stringValue: tree.databaseName))
        metaElement.addChild(xmlElement(name: .DatabaseNameChanged, date: tree.databaseNameChanged))
        metaElement.addChild(xmlElement(name: .DatabaseDescription, stringValue: tree.databaseDescription))
        metaElement.addChild(xmlElement(name: .DatabaseDescriptionChanged, date: tree.databaseDescriptionChanged))
        metaElement.addChild(xmlElement(name: .DefaultUserName, stringValue: tree.defaultUserName))
        metaElement.addChild(xmlElement(name: .MaintainanceHistoryDays, number: tree.maintainanceHistoryDays))
        metaElement.addChild(xmlElement(name: .Color))
        metaElement.addChild(xmlElement(name: .MasterKeyChanged, date: tree.masterKeyChanged))
        metaElement.addChild(xmlElement(name: .MasterKeyChangedRec, number: tree.masterKeyChangeRec))
        metaElement.addChild(xmlElement(name: .MasterKeyChangeForce, number: tree.masterKeyChangeForce));

        let memoryProtection = xmlElement(name: .MemoryProtection)
        memoryProtection.addChild(xmlElement(name: .ProtectTitle, bool: tree.memoryProtection.protectTitle))
        memoryProtection.addChild(xmlElement(name: .ProtectUserName, bool: tree.memoryProtection.protectUserName))
        memoryProtection.addChild(xmlElement(name: .ProtectPassword, bool: tree.memoryProtection.protectPassword))
        memoryProtection.addChild(xmlElement(name: .ProtectURL, bool: tree.memoryProtection.protectURL))
        memoryProtection.addChild(xmlElement(name: .ProtectNotes, bool: tree.memoryProtection.protectNotes))
        metaElement.addChild(memoryProtection)

        metaElement.addChild(xmlElement(name: .RecycleBinEnabled, bool: tree.recycleBinEnabled))
        metaElement.addChild(xmlElement(name: .RecycleBinUUID, uuid: tree.recycleBinUUID))
        metaElement.addChild(xmlElement(name: .RecycleBinChanged, date: tree.recycleBinChanged))
        metaElement.addChild(xmlElement(name: .EntryTemplatesGroup, uuid: tree.entryTemplatesGroup))
        metaElement.addChild(xmlElement(name: .EntryTemplatesGroupChanged, date: tree.entryTemplatesGroupChanged))
        metaElement.addChild(xmlElement(name: .HistoryMaxItems, number: tree.historyMaxItems))
        metaElement.addChild(xmlElement(name: .HistoryMaxSize, number: tree.historyMaxSize))
        metaElement.addChild(xmlElement(name: .LastSelectedGroup, uuid: tree.lastSelectedGroup))
        metaElement.addChild(xmlElement(name: .LastTopVisibleGroup, uuid: tree.lastTopVisibleGroup))

        return metaElement
    }

    func buildRoot() -> XMLElement {
        let rootElement = xmlElement(name: .Root)
        rootElement.addChild(buildGroup(tree.group!))
        return rootElement
    }

    func buildGroup(_ group: Kdb.Group) -> XMLElement {
        let groupElement = xmlElement(name: .Group)
        groupElement.addChild(xmlElement(name: .UUID, uuid: group.uuid))
        groupElement.addChild(xmlElement(name: .Name, stringValue: group.name))
        groupElement.addChild(xmlElement(name: .Notes, stringValue: group.notes))
        groupElement.addChild(xmlElement(name: .IconID, number: group.iconID))
        groupElement.addChild(xmlElement(name: .IsExpanded, bool: false))
        groupElement.addChild(xmlElement(name: .EnableAutoType, bool: false))
        groupElement.addChild(xmlElement(name: .EnableSearching, bool: true))
        groupElement.addChild(xmlElement(name: .LastTopVisibleEntry, uuid: UUID.zero))

        let timesElement = xmlElement(name: .Times)
        timesElement.addChild(xmlElement(name: .LastModificationTime, date: group.times.lastModificationTime))
        timesElement.addChild(xmlElement(name: .CreationTime, date: group.times.creationTime))
        timesElement.addChild(xmlElement(name: .LastAccessTime, date: group.times.lastAccessTime))
        timesElement.addChild(xmlElement(name: .ExpiryTime, date: group.times.expiryTime))
        timesElement.addChild(xmlElement(name: .Expires, bool: group.times.expires))
        timesElement.addChild(xmlElement(name: .UsageCount, number: group.times.usageCount))
        timesElement.addChild(xmlElement(name: .LocationChanged, date: group.times.locationChanged))
        groupElement.addChild(timesElement)

        for childGroup in group.groups {
            groupElement.addChild(buildGroup(childGroup))
        }

        for childEntry in group.entries {
            groupElement.addChild(buildEntry(childEntry))
        }

        return groupElement
    }

    func buildEntry(_ entry: Kdb.Entry) -> XMLElement {
        let entryElement = xmlElement(name: .Entry)
        entryElement.addChild(xmlElement(name: .UUID, uuid: entry.uuid))
        entryElement.addChild(xmlElement(name: .IconID, number: entry.iconID))
        entryElement.addChild(xmlElement(name: .ForegroundColor, data: entry.foregroundColor))
        entryElement.addChild(xmlElement(name: .BackgroundColor, data: entry.backgroundColor))
        entryElement.addChild(xmlElement(name: .OverrideURL, bool: entry.overrideURL))
        entryElement.addChild(xmlElement(name: .Tags, stringValue: entry.tags))

        let timesElement = xmlElement(name: .Times)
        timesElement.addChild(xmlElement(name: .LastModificationTime, date: entry.times.lastModificationTime))
        timesElement.addChild(xmlElement(name: .CreationTime, date: entry.times.creationTime))
        timesElement.addChild(xmlElement(name: .LastAccessTime, date: entry.times.lastAccessTime))
        timesElement.addChild(xmlElement(name: .ExpiryTime, date: entry.times.expiryTime))
        timesElement.addChild(xmlElement(name: .Expires, bool: entry.times.expires))
        timesElement.addChild(xmlElement(name: .UsageCount, number: entry.times.usageCount))
        timesElement.addChild(xmlElement(name: .LocationChanged, date: entry.times.locationChanged))
        entryElement.addChild(timesElement)

        for stringField in entry.strings {
            entryElement.addChild(buildString(stringField))
        }

        return entryElement
    }

    func buildString(_ string: Kdb.StringField) -> XMLElement {
        let stringElement = xmlElement(name: .String)
        stringElement.addChild(xmlElement(name: .Key, stringValue: string.key))
        stringElement.addChild(xmlElement(name: .Value, stringValue: string.value))

        if string.isProtected {
            if let attr = XMLNode.attribute(withName: "Protected", stringValue: "True") as? XMLNode {
                stringElement.addChild(attr)
            }
        }

        return stringElement
    }

    func xmlElement(name: Kdb4Node) -> XMLElement {
        return XMLElement(name: name.rawValue)
    }

    func xmlElement(name: Kdb4Node, stringValue value: String?) -> XMLElement {
        return XMLElement(name: name.rawValue, stringValue: value)
    }

    func xmlElement(name: Kdb4Node, data: Data? = nil) -> XMLElement {
        let base64Str = data?.base64EncodedString()
        return XMLElement(name: name.rawValue, stringValue: base64Str)
    }

    func xmlElement(name: Kdb4Node, date dateOrNil: Date? = nil) -> XMLElement {
        var stringValue: String?
        if let date = dateOrNil {
            stringValue = dateFormatter.string(from: date)
        }
        return XMLElement(name: name.rawValue, stringValue: stringValue)
    }

    func xmlElement(name: Kdb4Node, number numberOrNil: Int? = nil) -> XMLElement {
        var stringValue: String?
        if let number = numberOrNil {
            stringValue = String(number)
        }
        return XMLElement(name: name.rawValue, stringValue: stringValue)
    }

    func xmlElement(name: Kdb4Node, bool boolOrNil: Bool? = nil) -> XMLElement {
        var stringValue: String? = "False"
        if let value = boolOrNil, value == true {
            stringValue = "True"
        }
        return XMLElement(name: name.rawValue, stringValue: stringValue)
    }

    func xmlElement(name: Kdb4Node, uuid uuidOrNil: UUID? = nil) -> XMLElement {
        var data = Data(count: 16)
        if let uuid = uuidOrNil {
            data.withUnsafeMutableBytes { (urbp) -> Void in
                let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
                let unsafePointer = unsafeBufferPointer.baseAddress!
                unsafePointer[0] = uuid.uuid.0
                unsafePointer[1] = uuid.uuid.1
                unsafePointer[2] = uuid.uuid.2
                unsafePointer[3] = uuid.uuid.3
                unsafePointer[4] = uuid.uuid.4
                unsafePointer[5] = uuid.uuid.5
                unsafePointer[6] = uuid.uuid.6
                unsafePointer[7] = uuid.uuid.7
                unsafePointer[8] = uuid.uuid.8
                unsafePointer[9] = uuid.uuid.9
                unsafePointer[10] = uuid.uuid.10
                unsafePointer[11] = uuid.uuid.11
                unsafePointer[12] = uuid.uuid.12
                unsafePointer[13] = uuid.uuid.13
                unsafePointer[14] = uuid.uuid.14
                unsafePointer[15] = uuid.uuid.15
            }
        }
        return XMLElement(name: name.rawValue, stringValue: data.base64EncodedString())
    }
}
