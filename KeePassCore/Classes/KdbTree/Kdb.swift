//
//  Kdb.swift
//  KeePassCore
//
//  Created by Igor Kotkovets on 12/8/19.
//

import Foundation

enum Kdb4Node: String {
    case KeePassFile
    case Meta
    case Generator
    case HeaderHash
    case DatabaseName
    case DatabaseNameChanged
    case DatabaseDescription
    case DatabaseDescriptionChanged
    case DefaultUserName
    case DefaultUserNameChanged
    case MaintainanceHistoryDays
    case Color
    case MasterKeyChanged
    case MasterKeyChangedRec
    case MasterKeyChangeForce
    case MemoryProtection
    case ProtectTitle
    case ProtectUserName
    case ProtectPassword
    case ProtectURL
    case ProtectNotes
    case RecycleBinEnabled
    case RecycleBinUUID
    case RecycleBinChanged
    case EntryTemplatesGroup
    case EntryTemplatesGroupChanged
    case HistoryMaxItems
    case HistoryMaxSize
    case LastSelectedGroup
    case LastTopVisibleGroup
    case Binaries
    case CustomData
    case Root
    case Group
    case IconID
    case IsExpanded
    case DefaultAutoTypeSequence
    case EnableAutoType
    case EnableSearching
    case LastTopVisibleEntry
    case UUID
    case Name
    case Notes
    case Times
    case LastModificationTime
    case CreationTime
    case LastAccessTime
    case ExpiryTime
    case Expires
    case UsageCount
    case LocationChanged
    case Entry
    case ForegroundColor
    case BackgroundColor
    case OverrideURL
    case Tags
    case String
    case Key
    case Value
}


public struct Kdb {
    public class Tree: Node {
        public var generator: String?
        public var headerHash: Data?
        public var databaseName: String?
        public var databaseNameChanged: Date?
        public var databaseDescription: String?
        public var databaseDescriptionChanged: Date?
        public var defaultUserName: String?
        public var defaultUserNameChanged: Date?
        public var maintainanceHistoryDays: Int?
        public var color: UIColor?
        public var masterKeyChanged: Date?
        public var masterKeyChangeRec: Int?
        public var masterKeyChangeForce: Int?
        public var memoryProtection: MemoryProtection = MemoryProtection()
        public var recycleBinEnabled: Bool?
        public var recycleBinUUID: UUID?
        public var recycleBinChanged: Date?
        public var entryTemplatesGroup: UUID?
        public var entryTemplatesGroupChanged: Date?
        public var historyMaxItems: Int?
        public var historyMaxSize: Int?
        public var lastSelectedGroup: UUID?
        public var lastTopVisibleGroup: UUID?
        public var binaries: Data?
        public var customData: Data?
        public var group: Group?
        public var deletedObjects = [DeletedObject]()

        func addGroupToRecycleBinIfNeeded(_ group: Group) {
            if let recycleBinGroup = recycleBinGroup {
                if group.hasParent(recycleBinGroup) == false {
                    recycleBinGroup.add(group)
                }
            }
            else {
                let recycleBinGroup = Group(name: "Recycle Bin")
                addRecycleBinGroup(recycleBinGroup)
                recycleBinGroup.add(group)
            }
        }

        func addEntryToRecycleBinIfNeeded(_ entry: Entry) {
            if let recycleBinGroup = recycleBinGroup {
                if entry.hasParent(recycleBinGroup) == false {
                    recycleBinGroup.add(entry)
                }
            }
            else {
                let recycleBinGroup = Group(name: "Recycle Bin")
                addRecycleBinGroup(recycleBinGroup)
                recycleBinGroup.add(entry)
            }
        }

        func addRecycleBinGroup(_ group: Group) {
            self.recycleBinEnabled = true
            self.recycleBinUUID = group.uuid
            self.group?.add(group)
        }

        var recycleBinGroup: Group? {
            if let uuid = recycleBinUUID {
                return group?.groups.first(where: { $0.uuid == uuid })
            }
            else {
                return nil
            }
        }

    }

    public class MemoryProtection: Node {
        public var protectTitle: Bool?
        public var protectUserName: Bool?
        public var protectPassword: Bool?
        public var protectURL: Bool?
        public var protectNotes: Bool?
    }

    public class DeletedObject: Node {
        public var uuid: UUID?
        public var deletionTime: Date?
    }

    public class Group: Node {
        weak var parent: Node? = nil
        weak var tree: Tree? = nil

        public var uuid: UUID?
        public var name: String?
        public var notes: String?
        public var iconID: Int?
        public var times: Times = Times()
        public var isExpanded: Bool?
        public var defaultAutoTypeSequence: Data?
        public var enableAutoType: Data?
        public var enableSearching: Bool?
        public var lastTopVisibleEntry: UUID?
        public private(set) var groups = [Group]()
        public private(set) var entries = [Entry]()

        init(name: String, date: Date = Date()) {
            self.uuid = UUID()
            self.name = name
            self.notes = nil
            self.iconID = -1
            self.times.lastModificationTime = date
            self.times.creationTime =  date
            self.times.lastAccessTime = date
            self.times.expiryTime = date
            self.times.expires = false
            self.times.usageCount = 0
            self.times.locationChanged = date
            self.isExpanded = false
            self.defaultAutoTypeSequence = nil
            self.enableAutoType = nil
            self.enableSearching = true
            self.lastTopVisibleEntry = nil
        }

        public func add(_ group: Group) {
            group.parent = self;
            group.tree = tree
            groups.append(group)
        }

        public func remove(_ group: Group) {
            if let index = groups.firstIndex(where: { $0.uuid == group.uuid }) {
                let groupToDelete = groups.remove(at: index)

                tree?.addGroupToRecycleBinIfNeeded(groupToDelete)
            }

            groups.removeAll { (iteratable) -> Bool in
                iteratable.uuid == group.uuid
            }
        }

        public func add(_ entry: Entry) {
            entry.parent = self
            entry.tree = tree
            entries.append(entry)
        }

        public func remove(_ entry: Entry) {
            if let index = entries.firstIndex(where: { $0.uuid == entry.uuid }) {
                let entryToDelete = entries.remove(at: index)
                tree?.addEntryToRecycleBinIfNeeded(entryToDelete)
            }
        }

        public func addNewGroup(name: String) -> Group {
            let newGroup = Group(name: name)
            newGroup.parent = self
            newGroup.tree = tree
            groups.append(newGroup)
            return newGroup
        }

        public func addNewEntry() -> Entry {
            let newEntry = Entry()
            newEntry.parent = self
            newEntry.tree = tree
            entries.append(newEntry)
            return newEntry
        }

        func hasParent(_ group: Group) -> Bool {
            var itParent = parent as? Group
            while itParent != nil {
                if itParent?.uuid == group.uuid {
                    return true
                }
                else {
                    itParent = itParent?.parent as? Group
                }
            }

            return false
        }
    }

    public class Times: Node {
        public var lastModificationTime: Date?
        public var creationTime: Date?
        public var lastAccessTime: Date?
        public var expiryTime: Date?
        public var expires: Bool?
        public var usageCount: Int?
        public var locationChanged: Date?

        override init() {
            let now = Date()
            lastModificationTime = now
            creationTime = now
            lastAccessTime = now
            expiryTime = now
            expires = false
            usageCount = 0
            locationChanged = now
        }
    }

    public class Entry: Node {
        weak var parent: Node? = nil
        weak var tree: Tree? = nil

        public var uuid: UUID?
        public var iconID: Int?
        public var foregroundColor: Data?
        public var backgroundColor: Data?
        public var overrideURL: Bool?
        public var tags: String?
        public var times: Times = Times()
        public private(set) var strings = [StringField]()

        public override init() {
            self.uuid = UUID()
            self.iconID = 0
            self.foregroundColor = nil
            self.backgroundColor = nil
            self.overrideURL = false
            self.tags = nil
            let now = Date()
            self.times.lastModificationTime = now
            self.times.creationTime =  now
            self.times.lastAccessTime = now
            self.times.expiryTime = nil
            self.times.expires = false
            self.times.usageCount = 0
            self.times.locationChanged = nil
        }

        public func add(_ string: StringField) {
            strings.append(string)
        }

        public func remove(_ string: StringField) {
            strings.removeAll(where: { $0 === string } )
        }

        func hasParent(_ group: Group) -> Bool {
            var itParent = parent as? Group
            while itParent != nil {
                if itParent?.uuid == group.uuid {
                    return true
                }
                else {
                    itParent = itParent?.parent as? Group
                }
            }

            return false
        }
    }

    public class Node {

    }

    public class StringField {
        public enum DefaultKeys: String, CaseIterable {
            case Title
            case UserName
            case Password
            case URL
            case Notes
        }

        public var key: String
        public var value: String?
        public var isProtected: Bool

        public init(withKey: String, value: String? = nil, isProtected: Bool = false) {
            self.key = withKey
            self.value = value
            self.isProtected = isProtected
        }
    }
}


