//
//  KeePassCore.swift
//  Pods
//
//  Created by Igor Kotkovets on 10/8/17.
//

import Foundation
import CommonCrypto

public enum CompressionAlgorithm: UInt64 {
    case none = 0
    case gzip = 1
    case count = 2
}

public enum RandomStreamId: UInt64 {
    case none = 0
    case arc4varian = 1
    case salsa20 = 2
    case csrcount = 3
}

func computeHash(_ data: Data) -> Data {
    let resultPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes { (urbp) -> Void in
        CC_SHA256(urbp.baseAddress!, CC_LONG(data.count), resultPtr)
    }

    let result = Data(bytes: resultPtr, count: Int(CC_SHA256_DIGEST_LENGTH))
    return result

}
