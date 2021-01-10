//
//  InputStream.swift
//  Pods
//
//  Created by Igor Kotkovets on 9/16/17.
//
//

extension InputStream {
    func readUInt8() -> UInt8 {
        var uint8: UInt8 = 0
        withUnsafeMutablePointer(to: &uint8) { bytes -> Void in
            _ = self.read(bytes, maxLength: MemoryLayout<UInt8>.size)
        }
        return uint8
    }

    func readUInt16() -> UInt16 {
        var uint16: UInt16 = 0
        let bytesCount = MemoryLayout<UInt16>.size
        withUnsafeMutablePointer(to: &uint16) { uint16Ptr -> Void in
            uint16Ptr.withMemoryRebound(to: UInt8.self, capacity: bytesCount) { (uint8Ptr) -> Void in
                _ = self.read(uint8Ptr, maxLength: bytesCount)
            }
        }
        return uint16
    }

    func readUInt32() -> UInt32 {
        var result: UInt32 = 0
        let bytesCount = MemoryLayout<UInt32>.size
        withUnsafeMutablePointer(to: &result) { (uint32Ptr) -> Void in
            uint32Ptr.withMemoryRebound(to: UInt8.self, capacity: bytesCount) { uint8Ptr -> Void in
                _ = self.read(uint8Ptr, maxLength: bytesCount)
            }
        }
        return result
    }

    func readDataOfLength(_ length: Int) -> Data {
        var data = Data(count: length)
        data.withUnsafeMutableBytes { (urbp) -> Void in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            _ = self.read(unsafePointer, maxLength: length)
        }

        return data
    }
}
