//
//  AesInputStream.swift
//  AESStream
//
//  Created by Igor Kotkovets on 12/3/17.
//

import Foundation
import CommonCrypto

public enum AesInputStreamError: Error {
    case invalidKeySize
    case creatingCryptorError
    case decryptingDataError
    case finishingDecriptingError
}

public class AesInputStream: InputStream {
    static let aesBufferSize = 512*1024
    let inputStream: InputStream
    var cryptorRef: CCCryptorRef?
    var bufferSize: Int = 0
    var bufferOffset: Int = 0
    var eofReached = false
    var inputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: AesInputStream.aesBufferSize)
    var outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: AesInputStream.aesBufferSize)

    public init(with inputStream: InputStream, key: UnsafePointer<UInt8>, length: Int, vector: UnsafePointer<UInt8>) throws {
        guard length == 32 || length == 16 else {
            throw AesInputStreamError.invalidKeySize
        }

        self.inputStream = inputStream

        // CBC mode is selected by the absence of the kCCOptionECBMode bit in the options flags
        let result: CCCryptorStatus = CCCryptorCreate(CCOperation(kCCDecrypt),
                                                      CCAlgorithm(kCCAlgorithmAES128),
                                                      CCOptions(kCCOptionPKCS7Padding),
                                                      key,
                                                      length,
                                                      vector,
                                                      &cryptorRef)
        guard result == CCCryptorStatus(kCCSuccess) else {
            print(result.description())
            throw AesInputStreamError.creatingCryptorError
        }
    }

    public convenience init(with inputStream: InputStream, key: Data, vector: Data) throws {
        let keyPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: key.count)
        key.copyBytes(to: keyPtr, count: key.count)

        let vectorPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: vector.count)
        vector.copyBytes(to: vectorPtr, count: vector.count)

        try self.init(with: inputStream, key: keyPtr, length: key.count, vector: vectorPtr)

        keyPtr.deallocate()
        vectorPtr.deallocate()
    }

    deinit {
        inputBuffer.deallocate()
        outputBuffer.deallocate()
    }

    public var hasBytesAvailable: Bool {
        return !eofReached && bufferOffset < bufferSize
    }

    public func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength inLength: Int) -> Int {
        var remaining = inLength
        var offset = 0
        var actualLength = 0

        while remaining > 0 {
            if bufferOffset >= bufferSize {
                do {
                    let couldDecrypt = try decryptChunk()
                    if couldDecrypt == false {
                        return inLength - remaining
                    }
                } catch {}
            }

            actualLength = min(remaining, bufferSize-bufferOffset)
            (buffer+offset).initialize(from: outputBuffer+bufferOffset, count: actualLength)

            bufferOffset += actualLength
            offset += actualLength
            remaining -= actualLength
        }

        return offset
    }

    func decryptChunk() throws -> Bool {
        if eofReached == true {
            return false
        }

        bufferSize = 0
        bufferOffset = 0
        var decryptedBytes = 0
        let readLength = inputStream.read(inputBuffer, maxLength: AesInputStream.aesBufferSize)
        if readLength > 0 {
            let cryptorStatus = CCCryptorUpdate(cryptorRef,
                                                inputBuffer,
                                                readLength,
                                                outputBuffer,
                                                AesInputStream.aesBufferSize,
                                                &decryptedBytes)
            guard cryptorStatus == CCCryptorStatus(kCCSuccess) else {
                print(cryptorStatus.description())
                throw AesInputStreamError.decryptingDataError
            }

            bufferSize += decryptedBytes
        }

        if readLength < AesInputStream.aesBufferSize {
            let cryptorStatus = CCCryptorFinal(cryptorRef,
                                               outputBuffer+decryptedBytes,
                                               AesInputStream.aesBufferSize - decryptedBytes,
                                               &decryptedBytes)
            guard cryptorStatus == CCCryptorStatus(kCCSuccess) else {
                print(cryptorStatus.description())
                throw AesInputStreamError.finishingDecriptingError
            }

            eofReached = true
            bufferSize += decryptedBytes
        }

        return true
    }
}

public extension CCCryptorStatus {
    func description() -> String {
        if self == CCCryptorStatus(kCCParamError) {
            return "Illegal parameter value."
        } else if self == CCCryptorStatus(kCCBufferTooSmall) {
            return "Insufficent buffer provided for specified operation."
        } else if self == CCCryptorStatus(kCCMemoryFailure) {
            return "Memory allocation failure."
        } else if self == CCCryptorStatus(kCCAlignmentError) {
            return "Input size was not aligned properly."
        } else if self == CCCryptorStatus(kCCDecodeError) {
            return "Input data did not decode or decrypt properly."
        } else if self == CCCryptorStatus(kCCUnimplemented) {
            return "Function not implemented for the current algorithm."
        } else if self == CCCryptorStatus(kCCOverflow) {
            return "kCCOverflow."
        } else if self == CCCryptorStatus(kCCRNGFailure) {
            return "kCCRNGFailure."
        } else if self == CCCryptorStatus(kCCUnspecifiedError) {
            return "kCCUnspecifiedError."
        } else if self == CCCryptorStatus(kCCCallSequenceError) {
            return "kCCCallSequenceError."
        } else if self == CCCryptorStatus(kCCKeySizeError) {
            return "Invalid key size."
        }

        return "Undefined error \(self)."
    }
}

public enum AesOutputStreamError: Error {
    case invalidKeySize
    case creatingCryptorError
    case decryptingDataError
    case finishingDecriptingError

    case failFinishEncrypt(CCCryptorStatus)
    case failProcessData(CCCryptorStatus)
}

public class AesOutputStream: OutputStream {
    var bufferSize = 0
    var cryptorRef: CCCryptorRef?
    var cryptorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 0)
    let outputStream: OutputStream

    public init(with outputStream: OutputStream, key: UnsafePointer<UInt8>, length: Int, vector: UnsafePointer<UInt8>) throws {
        guard length == 32 || length == 16 else {
            throw AesInputStreamError.invalidKeySize
        }

        self.outputStream = outputStream
        // CBC mode is selected by the absence of the kCCOptionECBMode bit in the options flags
        let result: CCCryptorStatus = CCCryptorCreate(CCOperation(kCCEncrypt),
                                                      CCAlgorithm(kCCAlgorithmAES128),
                                                      CCOptions(kCCOptionPKCS7Padding),
                                                      key,
                                                      length,
                                                      vector,
                                                      &cryptorRef)
        guard result == CCCryptorStatus(kCCSuccess) else {
            print(result.description())
            throw AesInputStreamError.creatingCryptorError
        }
    }

    public convenience init(with outputStream: OutputStream, key: Data, vector: Data) throws {
        let keyPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: key.count)
        key.copyBytes(to: keyPtr, count: key.count)

        let vectorPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: vector.count)
        vector.copyBytes(to: vectorPtr, count: vector.count)

        try self.init(with: outputStream, key: keyPtr, length: key.count, vector: vectorPtr)

        keyPtr.deallocate()
        vectorPtr.deallocate()
    }

    deinit {
        cryptorBuffer.deallocate()
    }

    public var hasSpaceAvailable: Bool {
        return outputStream.hasSpaceAvailable
    }

    public func write(_ buffer: UnsafePointer<UInt8>, maxLength inLength: Int) throws -> Int {
        extendsBufferForCapacityIfNeeded(CCCryptorGetOutputLength(cryptorRef, inLength, false))

        var encryptedBytes = 0
        let cryptorStatus = CCCryptorUpdate(cryptorRef,
                                            buffer,
                                            inLength,
                                            cryptorBuffer,
                                            bufferSize,
                                            &encryptedBytes)
        guard cryptorStatus == CCCryptorStatus(kCCSuccess) else {
            print(cryptorStatus.description())
            throw AesOutputStreamError.failProcessData(cryptorStatus)
        }

        return try outputStream.write(cryptorBuffer, maxLength: encryptedBytes)
    }

    public func close() throws {
        var encryptedBytes = 0
        let cryptorStatus = CCCryptorFinal(cryptorRef,
                                           cryptorBuffer,
                                           bufferSize,
                                           &encryptedBytes)
        guard cryptorStatus == CCCryptorStatus(kCCSuccess) else {
            print(cryptorStatus.description())
            throw AesOutputStreamError.failFinishEncrypt(cryptorStatus)
        }

        _ = try outputStream.write(cryptorBuffer, maxLength: encryptedBytes)

        try outputStream.close()
    }

    func extendsBufferForCapacityIfNeeded(_ requiredCapacity: Int) {
        if requiredCapacity > bufferSize {
            cryptorBuffer.deallocate()
            cryptorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: requiredCapacity)
            bufferSize = requiredCapacity
        }
    }
}
