//
//  StdTypes+Extensions.swift
//  XML2Swift
//
//  Created by Igor Kotkovets on 12/22/17.
//

import Foundation

public extension FixedWidthInteger {
    func hexString(withAdding prefix: String? = nil) -> String {
        var copy = self

        return withUnsafePointer(to: &copy) { ptr -> String in
            let count = MemoryLayout<Self>.size
            return ptr.withMemoryRebound(to: UInt8.self, capacity: count) { (bytes) -> String in
                var str: String = prefix ?? ""
                for i in 0..<count {
                    str += String(format: "%02x", bytes[i])
                }
                return str
            }
        }
    }
}

public extension UnsafeMutablePointer where Pointee: FixedWidthInteger {
    public func isEqual(to buffer: UnsafeMutablePointer<Pointee>, ofLength length: Int) -> Bool {
        for i in 0..<length where self[i] != buffer[i] {
            return false
        }

        return true
    }

    public func isEqual(to buffer: UnsafePointer<Pointee>, ofLength length: Int) -> Bool {
        for i in 0..<length where self[i] != buffer[i] {
            return false
        }

        return true
    }

    public func hexString(ofLength len: Int, withAdding prefix: String? = nil) -> String {
        let count = MemoryLayout<Pointee>.size
        return self.withMemoryRebound(to: UInt8.self, capacity: count) { (bytes) -> String in
            var str: String = prefix ?? ""
            for i in 0..<count*len {
                str += String(format: "%02x", bytes[i])
            }
            return str
        }
    }
}

public extension UnsafePointer where Pointee: FixedWidthInteger {
    public func isEqual(to buffer: UnsafePointer<Pointee>, ofLength length: Int) -> Bool {
        for i in 0..<length where self[i] != buffer[i] {
            return false
        }

        return true
    }

    public func isEqual(to buffer: UnsafeMutablePointer<Pointee>, ofLength length: Int) -> Bool {
        for i in 0..<length where self[i] != buffer[i] {
            return false
        }

        return true
    }

    public func hexString(ofLength len: Int, withAdding prefix: String? = nil) -> String {
        let count = MemoryLayout<Pointee>.size
        return self.withMemoryRebound(to: UInt8.self, capacity: count) { (bytes) -> String in
            var str: String = prefix ?? ""
            for i in 0..<count*len {
                str += String(format: "%02x", bytes[i])
            }
            return str
        }
    }
}

extension String {
    func xmlChar() -> [UInt8]? {
        guard let cStr = cString(using: .utf8) else {
            return nil
        }

        return cStr.withUnsafeBytes {
            return Array($0)
        }
    }
}

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

