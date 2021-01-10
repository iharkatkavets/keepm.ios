//
//  KdbSignatureReader.swift
//  AppAuth
//
//  Created by Igor Kotkovets on 1/17/20.
//

import Foundation

public struct KdbSignature: Equatable, CustomDebugStringConvertible {
    public let basePrefix: UInt32
    public let kdbVersion: UInt32
    public let fileVersionMajor: UInt16
    public let fileVersionMinor: UInt16


    static func v2(majorFileVersion: UInt16, minorFileVersion: UInt16) -> KdbSignature {
        return KdbSignature(basePrefix: BASE_SIGNATURE_UINT32,
                            kdbVersion: KDB2_SIGNATURE_UINT32,
                            fileVersionMajor: majorFileVersion,
                            fileVersionMinor: minorFileVersion)
    }

    public var debugDescription: String {
        let addressStr = withUnsafePointer(to: self) { return String(format: "%p", $0) }
        return """
        <\(type(of: self)): \(addressStr),
        \n\tbasePrefix:\(basePrefix)
        \n\tkdbVersion:\(kdbVersion),
        \n\tmajorVersion:\(fileVersionMajor),
        \n\tminorVersion:\(fileVersionMinor),
        >
        """
    }
}

public class KdbSignatureReader {
    public init() {}

    public func readSignature(_ stream: InputStream) -> KdbSignature {
        let base = stream.readUInt32()
        let kdbVersion = stream.readUInt32()
        let minorVersion = stream.readUInt16()
        let majorVersion = stream.readUInt16()

        let signature = KdbSignature(basePrefix: base,
                                     kdbVersion: kdbVersion,
                                     fileVersionMajor: majorVersion,
                                     fileVersionMinor: minorVersion)
        return signature
    }
}

class KdbSignatureWriter {
    enum WriterError: Error {
        case cantWriteSignature
    }

    func writeSignature(_ signature: KdbSignature, outputStream: OutputStream) throws {
        do {
            _ = try outputStream.writeUInt32(BASE_SIGNATURE_UINT32)
            _ = try outputStream.writeUInt32(KDB2_SIGNATURE_UINT32)
            let dataMinor = withUnsafeBytes(of: signature.fileVersionMinor) { Data($0) }
            let dataMajor = withUnsafeBytes(of: signature.fileVersionMajor) { Data($0) }
            let dataVersion = dataMinor + dataMajor
            _ = try outputStream.write(dataVersion)
        } catch  {
            throw WriterError.cantWriteSignature
        }

    }
}
