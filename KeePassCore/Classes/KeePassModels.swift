//
//  KeePassModels.swift
//  Pods
//
//  Created by Igor Kotkovets on 7/12/17.
//
//

import Foundation

//#define KDB3_SIG1 (0x9AA2D903)
//#define KDB3_SIG2 (0xB54BFB65)
//
//#define KDB3_VER  (0x00030004)
//#define KDB3_HEADER_SIZE (124)

enum KeeStoreV3: String {
    case case0 = "9AA2D903"
    case case1 = "B54BFB65"

    static var allValues: [KeeStoreV3] = [case0, case1]
}

enum KeeStoreV4: String {
    case case0 = "9AA2D903"
    case case1 = "B54BFB67"

    static var allValues: [KeeStoreV4] = [case0, case1]
}

public class KdbHeader {
    let identifier: HeaderIdentifier
    let length: UInt16
    let data: Data

    public init(with identifier: HeaderIdentifier, length: UInt16, data: Data) {
        self.identifier = identifier
        self.length = length
        self.data = data
    }

//    internal var data: Data {
//        let len = MemoryLayout<HeaderIdentifier>.size+MemoryLayout<UInt16>.size+Int(length)
//        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
//        var position = 0
//        (result+position)[position] = identifier.rawValue
//        position += 1
//        withUnsafeBytes(of: length.littleEndian) { (urbp) -> Void in
//            let unsafeBufferPointer = urbp.bindMemory(to: UInt8.self)
//            let unsafePointer = unsafeBufferPointer.baseAddress!
//            (result+position).initialize(from: unsafePointer, count: 2)
//        }
//        position += 2
//        (result+position).initialize(from: self.payload, count: Int(length))
//        let resultData = Data(bytes: result, count: len)
//        result.deallocate()
//        return resultData
//    }
}


public enum HeaderIdentifier: UInt8 {
    case endEntry = 0x00
    case comment = 0x01
    case cipherId = 0x02
    case compressionFlags = 0x03
    case masterSeed = 0x04
    case transformSeed = 0x05
    case transformRounds = 0x06
    case encryptionIV = 0x07
    case protectedStreamKey = 0x08
    case streamStartBytes = 0x09
    case innerRandomStreamId = 0x0a

    public static let orderedValues: [HeaderIdentifier] = [.comment,
                                                           .cipherId,
                                                           .compressionFlags,
                                                           .masterSeed,
                                                           .transformSeed,
                                                           .transformRounds,
                                                           .encryptionIV,
                                                           .protectedStreamKey,
                                                           .streamStartBytes,
                                                           .innerRandomStreamId,
                                                           .endEntry]

    var description: String {
        switch self {
        case .comment:
            return "comment"
        case .cipherId:
            return "cipherId"
        case .compressionFlags:
            return "compressionFlags"
        case .masterSeed:
            return "masterSeed"
        case .transformSeed:
            return "transformSeed"
        case .transformRounds:
            return "transformRounds"
        case .encryptionIV:
            return "encryptionIV"
        case .protectedStreamKey:
            return "protectedStreamKey"
        case .streamStartBytes:
            return "streamStartBytes"
        case .innerRandomStreamId:
            return "innerRandomStreamId"
        case .endEntry:
            return "endEntry"
        }
    }
}
