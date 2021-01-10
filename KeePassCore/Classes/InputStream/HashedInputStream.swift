//
//  HashedInputStream.swift
//  Pods
//
//  Created by Igor Kotkovets on 10/5/17.
//

import Foundation
import CommonCrypto

enum HashedInputStreamError: Error {
    case invalidBlockIndex
    case cantReadHashBlock
    case hashNotEqual
    case cantReadDataBlock
}

class HashedBlockInputStream: KeePassCore.InputStream {
    let hashBlockSize = 32
    let inputStream: InputStream
    var blockIndex: UInt32 = 0
    var bufferOffset = 0
    var bufferLength = 0
    var eofReached: Bool = false
    var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 0)

    init(with inputStream: InputStream) {
        self.inputStream = inputStream
    }

    var hasBytesAvailable: Bool {
        return !eofReached
    }

    func read(_ bytes: UnsafeMutablePointer<UInt8>, maxLength inBytesLength: Int) -> Int {
        var remaining = inBytesLength
        var offset = 0

        while remaining > 0 {
            if bufferOffset == bufferLength {
                do {
                    let couldDecompress = try readHashedBlock()
                    if couldDecompress == false {
                        return inBytesLength - remaining
                    }
                } catch {
                    print("Unable to decompress")
                }
            }

            let actualLength = min(remaining, bufferLength-bufferOffset)
            (bytes+offset).initialize(from: buffer+bufferOffset, count: actualLength)

            bufferOffset += actualLength
            offset += actualLength
            remaining -= actualLength
        }

        return offset
    }

    func readHashedBlock() throws -> Bool {
        if eofReached == true {
            return false
        }

        bufferOffset = 0
        if inputStream.readUInt32() != blockIndex {
            throw HashedInputStreamError.invalidBlockIndex
        }
        blockIndex += 1

        let hashBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: hashBlockSize)
        if inputStream.read(hashBytes, maxLength: hashBlockSize) != hashBlockSize {
            hashBytes.deallocate()
            throw  HashedInputStreamError.cantReadHashBlock
        }

        bufferLength = Int(inputStream.readUInt32())
        if bufferLength == 0 {
            if isTerminatingBlock(hashBytes) {
                hashBytes.deallocate()
                eofReached = true
            } else {
                 hashBytes.deallocate()
                 throw HashedInputStreamError.hashNotEqual
            }
            return false
        }

        buffer.deallocate()
        buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferLength)
        if inputStream.read(buffer, maxLength: bufferLength) != bufferLength {
            throw HashedInputStreamError.cantReadDataBlock
        }

        let resultHash = UnsafeMutablePointer<UInt8>.allocate(capacity: hashBlockSize)
        CC_SHA256(buffer, CC_LONG(bufferLength), resultHash)
        if resultHash.isEqual(to: hashBytes, ofLength: hashBlockSize) == false {
            resultHash.deallocate()
            hashBytes.deallocate()
            throw HashedInputStreamError.hashNotEqual
        }

        resultHash.deallocate()
        hashBytes.deallocate()

        return true
    }

    func isTerminatingBlock(_ memoryBlock: UnsafePointer<UInt8>) -> Bool {
        for i in 0..<hashBlockSize {
            if (memoryBlock+i).pointee != 0x00 {
                return false
            }
        }

        return true
    }
}


class HashedBlockOutputStream: OutputStream {
    let hashBlockSize = 32
    let outputStream: OutputStream

    var blockIndex: UInt32 = 0
    var bufferOffset = 0
    var bufferLength = 0
    var buffer: UnsafeMutablePointer<UInt8>

    deinit {
        buffer.deallocate()
    }

    init(with outputStream: OutputStream, blockSize: Int = 32) {
        self.outputStream = outputStream
        bufferLength = blockSize
        buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: blockSize)
    }

    var hasSpaceAvailable: Bool {
        return self.outputStream.hasSpaceAvailable
    }

    func write(_ inBuffer: UnsafePointer<UInt8>, maxLength inBytesLength: Int) throws -> Int {
        var length = inBytesLength
        var offset = 0
        var n = 0

        while length > 0 {
            if bufferOffset == bufferLength {
                try writeHashBlock()
            }

            n = min(bufferLength-bufferOffset, inBytesLength)
            (buffer+bufferOffset).initialize(from: (inBuffer+offset), count: n)
            bufferOffset += n

            offset += n
            length -= n
        }

        return inBytesLength
    }

    func writeHashBlock() throws {
        _ = try outputStream.writeUInt32(blockIndex)
        blockIndex += 1

        let hash = UnsafeMutablePointer<UInt8>.allocate(capacity: hashBlockSize)
        if bufferOffset > 0 {
            CC_SHA256(buffer, CC_LONG(bufferOffset), hash)
        } else {
            hash.initialize(repeating: 0, count: hashBlockSize)
        }

        _ = try outputStream.write(hash, maxLength: hashBlockSize)
        hash.deallocate()

        _ = try outputStream.writeUInt32(UInt32(bufferOffset))

        if bufferOffset > 0 {
            _ = try outputStream.write(buffer, maxLength: bufferOffset)
        }

        bufferOffset = 0
    }

    func close() throws {
        if bufferOffset > 0 {
            try writeLastBlock()
        }

        try writeTerminatingBlock()
        try outputStream.close()
    }

    func writeLastBlock() throws {
        try writeHashBlock()
    }

    func writeTerminatingBlock() throws {
        try writeHashBlock()
    }
}
