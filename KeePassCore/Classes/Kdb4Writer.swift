//
//  Kdb4Writer.swift
//  KeePassCore
//
//  Created by Igor Kotkovets on 1/12/20.
//

import Foundation
// https://habr.com/ru/post/346820/
// https://gist.github.com/lgg/e6ccc6e212d18dd2ecd8a8c116fb1e45

public enum KdbWriterError: Swift.Error {
    case randomDoesNotWork
}

public class Kdb4Writer {
    let masterSeed: Data
    let transformSeed: Data
    let encryptionIV: Data
    let protectedStreamKey: Data
    let streamStartBytes: Data
    let cachedParameters: DatabaseParameters

    public init(cachedParameters: DatabaseParameters) throws {
        guard let masterSeed = Data.random(count: 32),
            let transformSeed = Data.random(count: 32),
            let encryptionIV = Data.random(count: 16),
            let protectedStreamKey = Data.random(count: 32),
            let streamStartBytes = Data.random(count: 32) else {
            throw KdbWriterError.randomDoesNotWork
        }
        self.masterSeed = masterSeed
        self.transformSeed = transformSeed
        self.encryptionIV = encryptionIV
        self.protectedStreamKey = protectedStreamKey
        self.streamStartBytes = streamStartBytes
        self.cachedParameters = cachedParameters
    }

    public func write(_ outputStream: DataOutputStream) throws {
        try writeSignature(outputStream)
        try writeHeaders(outputStream)
        try writeTree(outputStream)
    }

    func writeSignature(_ outputStream: OutputStream) throws {
        let signatureWriter = KdbSignatureWriter()
        let signature = KdbSignature.v2(majorFileVersion: cachedParameters.fileVersionMajor,
                                        minorFileVersion: cachedParameters.fileVersionMinor)
        try signatureWriter.writeSignature(signature, outputStream: outputStream)
    }

    func writeHeaders(_ outputStream: OutputStream) throws {
        _ = try write(AES_CIPHER_UUID, headerId: .cipherId, to: outputStream)

        _ = try write(GZIP_COMPRESSION, headerId: .compressionFlags, to: outputStream)

        _ = try write(masterSeed, headerId: .masterSeed, to: outputStream)

        _ = try write(transformSeed, headerId: .transformSeed, to: outputStream)

        _ = try write(cachedParameters.transformRounds, headerId: .transformRounds, to: outputStream)

        _ = try write(encryptionIV, headerId: .encryptionIV, to: outputStream)

        _ = try write(protectedStreamKey, headerId: .protectedStreamKey, to: outputStream)

        _ = try write(streamStartBytes, headerId: .streamStartBytes, to: outputStream)

        _ = try write(RANDOM_STREAM_SALSA_20, headerId: .innerRandomStreamId, to: outputStream)

        _ = try write(Data([0x00,0x00,0x00,0x00]), headerId: .endEntry, to: outputStream)
    }

    func write(_ data: Data, headerId: HeaderIdentifier, to outputStream: OutputStream) throws -> Int {
        return try data.withUnsafeBytes { (urbp) -> Int in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            var totalWroteBytes = 0
            totalWroteBytes += try outputStream.write(headerId.rawValue)
            totalWroteBytes += try outputStream.write(UInt16(data.count))
            totalWroteBytes += try outputStream.write(unsafePointer, maxLength: Int(data.count))
            return totalWroteBytes
        }
    }

    func write<Value>(_ value: Value, headerId: HeaderIdentifier, to outputStream: OutputStream) throws -> Int where Value: FixedWidthInteger {
        return try withUnsafeBytes(of: value.littleEndian) { (urbp) -> Int in
            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
            let unsafePointer = unsafeBufferPointer.baseAddress!
            var totalWroteBytes = 0
            totalWroteBytes += try outputStream.write(headerId.rawValue)
            totalWroteBytes += try outputStream.write(UInt16(MemoryLayout<Value>.size))
            totalWroteBytes += try outputStream.write(unsafePointer, maxLength: Int(MemoryLayout<Value>.size))
            return totalWroteBytes
        }
    }

    func writeTree(_ inOutputStream: DataOutputStream) throws {
        let data = inOutputStream.data
        let headerHash = computeHash(data)

        cachedParameters.tree?.headerHash = headerHash
        cachedParameters.tree?.generator = KDB_GENERATOR

        let keyBuilder = Kdb4KeyBuilder()
        let key = try keyBuilder.createMasterKeyWith(credentials: cachedParameters.credentials!,
                                                     masterSeed: masterSeed,
                                                     transformSeed: transformSeed,
                                                     rounds: cachedParameters.transformRounds)

        let aesOutputStream = try AesOutputStream(with: inOutputStream, key: key,
                                                  vector: encryptionIV)
        _ = try aesOutputStream.write(streamStartBytes)

        let megaByte = 1024*1024
        var outputStream2: OutputStream = HashedBlockOutputStream(with: aesOutputStream,
                                                                 blockSize: megaByte)
        if self.cachedParameters.compressionAlgorithm == CompressionAlgorithm.gzip {
            outputStream2 = try GZipOutputStream(with: outputStream2)
        }

        let randomGenerator = try Salsa20Cipher(withKey: protectedStreamKey, iv: RANDOM_GENERATOR_IV)

        let xmlWriter = XMLWriter(tree: cachedParameters.tree!, outputStream: outputStream2, randomStream: randomGenerator)
        try xmlWriter.write()
        try outputStream2.close()
    }
}


