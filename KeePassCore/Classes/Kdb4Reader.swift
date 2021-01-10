//
//  KeePassReader.swift
//  Pods
//
//  Created by Igor Kotkovets on 8/6/17.
//
//

import Foundation
import CommonCrypto
import os.log

public enum KdbReaderError: Error {
    case readSignatureError
    case unsupportedFileVersion
    case uknownHeader
    case invalidHeader
    case invalidMasterSeed
    case invalidTransformSeed
    case invalidTransformRounds
    case invalidMasterKey
    case invalidStartBytes
    case invalidEncryptionIV
    case invalidAESParameters
    case startBytesNotEqual
    case invalidCompressionFlags
    case invalidXMLPayload
    case invalidRandomStreamId
    case invalidProtectedStreamKey
    case invalidRandomGenerator
    case unsupportedRandomGenerator
}

protocol KdbReaderInput {
    func readWithCredentials(_ credentials: KdbCredentials) throws -> DatabaseParameters
}

public class Kdb4Reader: KdbReaderInput {
    let inputStream: InputStream
    lazy var outLog = OSLog(subsystem: LOG_SUBSYSTEM, category: String(describing: self))
    lazy var signatureReader = KdbSignatureReader()

    public init(file stream: InputStream) {
        self.inputStream = stream
    }

    public func readWithCredentials(_ credentials: KdbCredentials) throws -> DatabaseParameters {
        do {
            let signature = try readSignature()
            let headers = try readHeaders()
            let parameters = try readTree(headers, credentials: credentials)
            parameters.fileVersionMajor = signature.fileVersionMajor
            parameters.fileVersionMinor = signature.fileVersionMinor
            return parameters
        } catch {
            throw KdbReaderError.readSignatureError
        }
    }

    func readSignature() throws -> KdbSignature {
        let signature = signatureReader.readSignature(inputStream)

        guard signature.basePrefix == BASE_SIGNATURE_UINT32 else {
            throw KdbReaderError.readSignatureError
        }

        guard signature.kdbVersion == KDB2_SIGNATURE_UINT32 else {
            throw KdbReaderError.unsupportedFileVersion
        }

        return signature
    }

    func readHeaders() throws -> KdbV4Headers {
        var headersResult = KdbV4Headers()
        forLoop: for _ in HeaderIdentifier.orderedValues {
            let identifierRawValue = inputStream.readUInt8()
            guard let parsedHeader: HeaderIdentifier = HeaderIdentifier(rawValue: identifierRawValue) else {
                throw KdbReaderError.invalidHeader
            }

            let payloadLength = inputStream.readUInt16()
            var data = Data(count: Int(payloadLength))
            let readLength = data.withUnsafeMutableBytes { (urbp) -> Int in
                let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
                let unsafePointer = unsafeBufferPointer.baseAddress!
                return inputStream.read(unsafePointer, maxLength: Int(payloadLength))
            }

            guard readLength == payloadLength else {
                os_log(.error, log: outLog, "read lenght (%d) doesn't match expected length (%d) with expected in %s header",
                       readLength, payloadLength, parsedHeader.description)
                throw KdbError.readInvalidHeaderLength
            }

            let readHeader = KdbHeader(with: parsedHeader, length: payloadLength, data: data)
            headersResult.add(header: readHeader)

            if parsedHeader == .endEntry {
                break forLoop
            }
        }

        os_log(.info, log: outLog, "headers: %s", headersResult.debugDescription)
        return headersResult
    }

    func readTree(_ headers: KdbV4Headers, credentials: KdbCredentials) throws -> DatabaseParameters {
        let keyBuilder = Kdb4KeyBuilder()
        let masterSeed = try obtainMasterSeed(from: headers)
        let transformSeed = try obtainTransformSeed(from: headers)
        let transformRounds = try obtainTransformRounds(from: headers)
        let aesKey = try keyBuilder.createMasterKeyWith(credentials: credentials,
                                                        masterSeed: masterSeed,
                                                        transformSeed: transformSeed,
                                                        rounds: transformRounds)
        let encryptionIV = try obtainEncryptionIV(from: headers)
        let aesStream = try AesInputStream(with: inputStream, key: aesKey, vector: encryptionIV)
        let startBytes = try obtainStartBytes(from: headers)
        try verifyStartBytes(inAesStream: aesStream, andCompareWith: startBytes)
        let algorithm = try obtainCompressionAlgorithm(from: headers)
        let streamId = try obtainRandomStreamId(from: headers)
        let streamKey = try obtainProtectedStreamKey(from: headers)
        let generator = try createRandomGenerator(streamId, withProtected: streamKey)
        let parsedTreeOrNil = try readPayload(inAesStream: aesStream,
                                              compressionAlgorithm: algorithm,
                                              randomGenerator: generator)
        let cachedParameters = DatabaseParameters()
        cachedParameters.tree = parsedTreeOrNil
        cachedParameters.credentials = credentials
        return cachedParameters
    }

    // veryfied
    func obtainMasterSeed(from headers: KdbV4Headers) throws -> Data {
        guard let payload = headers.getHeader(with: .masterSeed)?.data else {
                throw KdbReaderError.invalidMasterSeed
        }

        return payload
    }

    // veryfied
    func obtainTransformSeed(from headers: KdbV4Headers) throws -> Data {
        guard let payload = headers.getHeader(with: .transformSeed)?.data else {
                throw KdbReaderError.invalidTransformSeed
        }

        return payload
    }

    func obtainTransformRounds(from headers: KdbV4Headers) throws -> UInt64 {
        guard let payload = headers.getHeader(with: .transformRounds)?.data,
            let length = headers.getHeader(with: .transformRounds)?.length else {
                throw KdbReaderError.invalidTransformSeed
        }



        var rounds: UInt64 = 0
        withUnsafeMutablePointer(to: &rounds) { roundsPtr -> Void in
            roundsPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt64>.size) { bytes -> Void in
                payload.withUnsafeBytes { (urbp) -> Void in
                    let payloadPtr = urbp.bindMemory(to: UInt8.self).baseAddress!
                    bytes.initialize(from: payloadPtr, count: Int(length))
                }
            }
        }

        return rounds
    }

    func obtainCompressionAlgorithm(from headers: KdbV4Headers) throws -> CompressionAlgorithm {
        guard let payload = headers.getHeader(with: .compressionFlags)?.data,
            let length = headers.getHeader(with: .compressionFlags)?.length else {
                throw KdbReaderError.invalidCompressionFlags
        }

        var rawValue: UInt64 = 0
        withUnsafeMutablePointer(to: &rawValue) { rawValuePtr -> Void in
            rawValuePtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt64>.size) { bytes -> Void in
                payload.withUnsafeBytes { (urbp) -> Void in
                    let payloadPtr = urbp.bindMemory(to: UInt8.self).baseAddress!
                    bytes.initialize(from: payloadPtr, count: Int(length))
                }
            }
        }

        guard let algorithm = CompressionAlgorithm(rawValue: rawValue) else {
            throw KdbReaderError.invalidCompressionFlags
        }

        return algorithm
    }

    func obtainStartBytes(from headers: KdbV4Headers) throws -> Data {
        guard let startBytes = headers.getHeader(with: .streamStartBytes)?.data else {
            throw KdbReaderError.invalidStartBytes
        }

        return startBytes
    }

    func obtainEncryptionIV(from headers: KdbV4Headers) throws -> Data {
        guard let encryptionIV = headers.getHeader(with: .encryptionIV)?.data else {
                throw KdbReaderError.invalidEncryptionIV
        }

        return encryptionIV
    }

    func obtainRandomStreamId(from headers: KdbV4Headers) throws -> RandomStreamId {
        guard let randomStreamData = headers.getHeader(with: .innerRandomStreamId)?.data,
            let randomStreamDataLen = headers.getHeader(with: .innerRandomStreamId)?.length else {
                throw KdbReaderError.invalidRandomStreamId
        }

        var randomGeneratorRaw: UInt64 = 0
        withUnsafeMutablePointer(to: &randomGeneratorRaw) { randomGeneratorPtr -> Void in
            randomGeneratorPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt64>.size) { bytes -> Void in
                randomStreamData.withUnsafeBytes { (urbp) -> Void in
                    let randomStreamDataPtr = urbp.bindMemory(to: UInt8.self).baseAddress!
                    bytes.initialize(from: randomStreamDataPtr, count: Int(randomStreamDataLen))
                }
            }
        }

        guard let randomStreamId = RandomStreamId(rawValue: randomGeneratorRaw) else {
            throw KdbReaderError.invalidRandomStreamId
        }

        return randomStreamId
    }

    func obtainProtectedStreamKey(from headers: KdbV4Headers) throws -> Data {
        guard let protectedStreamKey = headers.getHeader(with: .protectedStreamKey)?.data,
            let protectedStreamKeyLen = headers.getHeader(with: .protectedStreamKey)?.length else {
                throw KdbReaderError.invalidProtectedStreamKey
        }

        var key = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        key.withUnsafeMutableBytes { bytes -> Void in
            let keyPtr = bytes.bindMemory(to: UInt8.self).baseAddress!
            protectedStreamKey.withUnsafeBytes { (urbp) -> Void in
                let protectedStreamKeyPtr = urbp.bindMemory(to: UInt8.self).baseAddress!
                CC_SHA256(protectedStreamKeyPtr, CC_LONG(protectedStreamKeyLen), keyPtr)
            }


        }
        // 572076e27ddc90ca659bb307411908e4080db92122c0c574bdc3c08da534e9d2
        return key
    }

    func createRandomGenerator(_ streamId: RandomStreamId,
                                      withProtected streamKey: Data) throws -> RandomGenerator {
        if streamId == .salsa20 {
            return try Salsa20Cipher(withKey: streamKey, iv: RANDOM_GENERATOR_IV)
        }
        throw KdbReaderError.unsupportedRandomGenerator
    }

    func verifyStartBytes(inAesStream: InputStream, andCompareWith expected: Data) throws {
        var startBytes = Data(count: 32)
        
        let readBytes = startBytes.withUnsafeMutableBytes { (urbp) -> Int in
            let unsafePointer = urbp.bindMemory(to: UInt8.self).baseAddress!
            return inAesStream.read(unsafePointer, maxLength: 32)
        }

        if readBytes != 32 || expected != startBytes {
            throw KdbReaderError.startBytesNotEqual
        }
    }

    func readPayload(inAesStream: InputStream, compressionAlgorithm: CompressionAlgorithm,
                     randomGenerator: RandomGenerator) throws -> Kdb.Tree {
        var inputStream: InputStream = HashedBlockInputStream(with: inAesStream)
        if compressionAlgorithm == .gzip {
            inputStream = try GZipInputStream(with: inputStream)
        }

        let kdbParser = XMLReader(withRandom: randomGenerator)
        guard let tree = kdbParser.parse(inputStream: inputStream) else {
            throw KdbReaderError.invalidXMLPayload
        }

        return tree
    }
}
