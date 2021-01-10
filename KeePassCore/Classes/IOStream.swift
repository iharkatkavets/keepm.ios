//
//  InputStream.swift
//  Pods
//
//  Created by Igor Kotkovets on 11/3/17.
//

public protocol InputStream {
    var hasBytesAvailable: Bool { get }
    func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int
}

public protocol OutputStream {
    var hasSpaceAvailable: Bool { get }
    func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) throws -> Int
    func close() throws
}

public extension OutputStream {
    func write<Value>(_ value: Value) throws -> Int where Value: FixedWidthInteger {
        return try withUnsafeBytes(of: value) { urbp -> Int in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            return try self.write(unsafePointer, maxLength: MemoryLayout<Value>.size)
        }
    }

    func write(_ data: Data) throws -> Int {
        return try data.withUnsafeBytes { (urbp) -> Int in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            return try self.write(unsafePointer, maxLength: data.count)
        }
    }

    func writeUInt32(_ value: UInt32) throws -> Int {
        return try write(value)
    }
}
