//
//  Data+Extensions.swift
//  KeePassCore
//
//  Created by igork on 1/13/20.
//

import Foundation


extension Data {
    func mjtWithUnsafePointer<ResultType>(_ body: (UnsafePointer<UInt8>) throws -> ResultType) rethrows -> ResultType {
        return try withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> ResultType in
            let unsafeBufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            guard let unsafePointer = unsafeBufferPointer.baseAddress else {
                var int: UInt8 = 0
                return try body(&int)
            }
            return try body(unsafePointer)
        }
    }

    static func random(count: Int) -> Data? {
        var data = Data(count: count)
        let result = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress!)
        }
        if result == errSecSuccess {
            return data
        } else {
            return nil
        }
    }

    func hexString(withAdding prefix: String? = nil) -> String {
        var result = prefix ?? ""
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count)

        for byte in bytes {
            result += String(format: "%02x", UInt(byte))
        }

        return result
    }

    init?(hex string: String) {
        let withoutSpaces = string.replacingOccurrences(of: " ", with: "")
        self.init(capacity: withoutSpaces.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in withoutSpaces.utf16 {
            guard let val = decodeNibble(character: c) else {
                return nil
            }

            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }

        guard even else {
            return nil
        }
    }

    // Convert 0 ... 9, a ... f, A ...F to their decimal value,
    // return nil for all other input characters
    private func decodeNibble(character: UInt16) -> UInt8? {
        switch character {
        case 0x30 ... 0x39: // 0..9
            return UInt8(character - 0x30)
        case 0x41 ... 0x46: // A..F
            return UInt8(character - 0x41 + 10)
        case 0x61 ... 0x66: // a..f
            return UInt8(character - 0x61 + 10)
        default:
            return nil
        }
    }
}
