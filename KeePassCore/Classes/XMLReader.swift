//
//  Kdb4Parser.swift
//  Pods
//
//  Created by Igor Kotkovets on 12/21/17.
//

import Foundation
import libxml2
import os.log

class XMLReader {
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

    let outputLog = OSLog(subsystem: "KeePassCore", category: "XMLReader")

    init(withRandom generator: RandomGenerator) {
        self.randomGenerator = generator
    }

    // swiftlint:disable force_cast
    func parse(inputStream: InputStream) -> Kdb.Tree? {
        let contextAsPtr = Unmanaged.passUnretained(inputStream as AnyObject).toOpaque()
        let xmlDocument = XMLDocument(withRead: { (ctx, int8Buffer, len) -> Int32 in
            let context: AnyObject = Unmanaged.fromOpaque(ctx!).takeUnretainedValue()
            let pstream = context as! InputStream
            return int8Buffer!.withMemoryRebound(to: UInt8.self, capacity: Int(len)) { (uin8Buffer) -> Int32 in
                let readLength = pstream.read(uin8Buffer, maxLength: Int(len))
                return Int32(readLength)
            }
        }, close: { _ -> Int32 in
            return 0
        }, context: contextAsPtr, options: 0)

        guard let keePassFileNode = xmlDocument?.rootElement() else {
            return nil
        }

        let tree = Kdb.Tree()
        if let metaElement = keePassFileNode.element(forName: "Meta") {
            parseMeta(metaElement, tree: tree)
        }

        if let rootNode = keePassFileNode.element(forName: "Root") {
            recursiveDecodeProtected(rootNode)
            parseRoot(rootNode, tree: tree)
        }

        return tree
    }
    // swiftlint:enable force_cast

    func parseMeta(_ metaNode: XMLElement, tree: Kdb.Tree) {
        tree.generator = metaNode.element(forName: "Generator")?.stringValue
        tree.headerHash = dataFromElement(metaNode, forName: "HeaderHash")
        
        tree.databaseName = metaNode.element(forName: "DatabaseName")?.stringValue
        tree.databaseNameChanged = dateFromElement(metaNode, forName: "DatabaseNameChanged")

        tree.databaseDescription = metaNode.element(forName: "DatabaseDescription")?.stringValue
        tree.databaseDescriptionChanged = dateFromElement(metaNode, forName: "DatabaseDescriptionChanged")

        tree.defaultUserName = metaNode.element(forName: "DefaultUserName")?.stringValue
        tree.defaultUserNameChanged = dateFromElement(metaNode, forName: "DefaultUserNameChanged")

        tree.maintainanceHistoryDays = intFromElement(metaNode, forName: "MaintenanceHistoryDays")

        tree.masterKeyChanged = dateFromElement(metaNode, forName: "MasterKeyChanged")
        tree.masterKeyChangeRec = intFromElement(metaNode, forName: "MasterKeyChangeRec")
        tree.masterKeyChangeForce = intFromElement(metaNode, forName: "MasterKeyChangeForce")

        tree.recycleBinEnabled = boolFromElement(metaNode, forName: "RecycleBinEnabled")
        tree.recycleBinUUID = uuidFromElement(metaNode, forName: "RecycleBinUUID")
        tree.recycleBinChanged = dateFromElement(metaNode, forName: "RecycleBinChanged")

        tree.entryTemplatesGroup = uuidFromElement(metaNode, forName: "EntryTemplatesGroup")
        tree.entryTemplatesGroupChanged = dateFromElement(metaNode, forName: "EntryTemplatesGroupChanged")

        tree.lastSelectedGroup = uuidFromElement(metaNode, forName: "LastSelectedGroup")
        tree.lastTopVisibleGroup = uuidFromElement(metaNode, forName: "LastTopVisibleGroup")

        tree.historyMaxItems = intFromElement(metaNode, forName: "HistoryMaxItems")
        tree.historyMaxSize = intFromElement(metaNode, forName: "HistoryMaxSize")

        if let memoryProtection = parseMemoryProtection(metaNode) {
            tree.memoryProtection = memoryProtection
        }
    }

    func parseMemoryProtection(_ element: XMLElement) -> Kdb.MemoryProtection? {
        if let memoryProtectionElement = element.element(forName: "MemoryProtection") {
            let memoryProtection = Kdb.MemoryProtection()
            memoryProtection.protectTitle = boolFromElement(memoryProtectionElement, forName: "ProtectTitle")
            memoryProtection.protectUserName = boolFromElement(memoryProtectionElement, forName: "ProtectUserName")
            memoryProtection.protectPassword = boolFromElement(memoryProtectionElement, forName: "ProtectPassword")
            memoryProtection.protectURL = boolFromElement(memoryProtectionElement, forName: "ProtectURL")
            memoryProtection.protectNotes = boolFromElement(memoryProtectionElement, forName: "ProtectNotes")
            return memoryProtection
        }
        else {
            return nil
        }
    }

    func recursiveDecodeProtected(_ node: XMLElement) {
        if let isProtected = node.attribute(forName: "Protected")?.stringValue,
            let encodedValueStr = node.stringValue,
            let encodedData = Data(base64Encoded: encodedValueStr),
            isProtected == "True" {
            let decodedBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: encodedData.count)
            defer {
                decodedBuffer.deallocate()
            }
            encodedData.withUnsafeBytes { (urbp) -> Void in
                let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
                let unsafePointer = unsafeBufferPointer.baseAddress!
                self.randomGenerator.xor(input: unsafePointer, output: decodedBuffer, length: encodedData.count)
            }
            let decryptedStr = String(bytesNoCopy: decodedBuffer, length: encodedData.count, encoding: .utf8, freeWhenDone: false)
            node.stringValue = decryptedStr
        }

        node.children?.forEach {
            if let element = $0 as? XMLElement {
                recursiveDecodeProtected(element)
            }
        }
    }

    func dataFromElement(_ xmlElement: XMLElement, forName name: String) -> Data? {
        if let node = xmlElement.element(forName: name),
            let stringValue = node.stringValue {
            return Data(base64Encoded: stringValue)
        }
        else {
            return nil
        }
    }

    func dateFromElement(_ xmlElement: XMLElement, forName name: String) -> Date? {
        if let node = xmlElement.element(forName: name) {
            return dateFrom(node.stringValue)
        }
        else {
            return nil
        }
    }

    func dateFrom(_ strOrNil: String?) -> Date? {
        if let str = strOrNil {
            return dateFormatter.date(from: str)
        } else {
            return nil
        }
    }

    func intFromElement(_ xmlElement: XMLElement, forName name: String) -> Int? {
        if let node = xmlElement.element(forName: name) {
            return intFrom(node.stringValue)
        }
        else {
            return nil
        }
    }

    func intFrom(_ strOrNil: String?) -> Int? {
        if let str = strOrNil {
            return Int(str)
        } else {
            return nil
        }
    }

    func boolFromElement(_ xmlElement: XMLElement, forName name: String) -> Bool? {
        if let node = xmlElement.element(forName: name) {
            return boolFrom(node.stringValue)
        }
        else {
            return nil
        }
    }

    func boolFrom(_ strOrNil: String?) -> Bool? {
        if let str = strOrNil {
            return Bool(str)
        } else {
            return nil
        }
    }

    func uuidFromElement(_ xmlElement: XMLElement, forName name: String) -> UUID? {
        if let stringValue = xmlElement.element(forName: name)?.stringValue,
            let data = Data(base64Encoded: stringValue) {
            let uuid = UUID(uuidData: data)
            return uuid
        }
        else {
            return nil
        }
    }

    func parseRoot(_ element: XMLElement, tree: Kdb.Tree) {
        if let groupElement = element.element(forName: "Group") {
            tree.group = parseGroup(groupElement)
        }

        if let deletedObjectsElement = element.element(forName: "DeletedObjects") {
            tree.deletedObjects = parseDeletedObjects(deletedObjectsElement)
        }
    }

    func parseGroup(_ element: XMLElement) -> Kdb.Group {
        let group = Kdb.Group(name: element.element(forName: "Name")?.stringValue ?? "")
        group.uuid =  parseUUID(element)
        group.notes = element.element(forName: "Notes")?.stringValue
        if let times = parseTimes(element) {
            group.times = times
        }

        group.isExpanded = boolFromElement(element, forName: "IsExpanded")

        for groupNode in element.elements(forName: "Group") {
            group.add(parseGroup(groupNode))
        }

        for entryNode in element.elements(forName: "Entry") {
            group.add(parseEntry(entryNode))
        }

        return group
    }

    func parseTimes(_ element: XMLElement) -> Kdb.Times? {
        if let timesElement = element.element(forName: "Times") {
            let times = Kdb.Times()
            times.lastModificationTime = dateFromElement(timesElement, forName: "LastModificationTime")
            times.creationTime = dateFromElement(timesElement, forName: "CreationTime")
            times.lastAccessTime = dateFromElement(timesElement, forName: "LastAccessTime")
            times.expiryTime = dateFromElement(timesElement, forName: "ExpiryTime")
            times.expires = boolFromElement(timesElement, forName: "Expires")
            times.usageCount = intFromElement(timesElement, forName:  "UsageCount")
            times.locationChanged = dateFromElement(timesElement, forName:  "LocationChanged")
            return times
        }
        else {
            return nil
        }
    }

    func parseEntry(_ element: XMLElement) -> Kdb.Entry {
        let entry = Kdb.Entry()
        entry.uuid = parseUUID(element)
        for stringNode in element.elements(forName: "String") {
            if let stringField = parseString(stringNode) {
                entry.add(stringField)
            }

        }
        return entry
    }

    func parseString(_ stringNode: XMLElement) -> Kdb.StringField? {
        if let key = stringNode.element(forName: "Key")?.stringValue,
            let valueNode = stringNode.element(forName: "Value") {
            var isProtected = false
            if let isProtectedString = valueNode.attribute(forName: "Protected")?.stringValue,
                isProtectedString == "True" {
                isProtected = true
            }
            let stringValue = Kdb.StringField(withKey: key, value: valueNode.stringValue, isProtected: isProtected)
            return stringValue
        } else {
            return nil
        }
    }

    func parseUUID(_ element: XMLElement) -> UUID? {
        if let uuidNode = element.element(forName: "UUID"),
            let stringValue = uuidNode.stringValue,
            let data = Data(base64Encoded: stringValue) {
            let uuid = UUID(uuidData: data)
            return uuid
        } else {
            return nil
        }
    }

    func parseDeletedObjects(_ element: XMLElement) -> [Kdb.DeletedObject] {
        return []
    }
}
