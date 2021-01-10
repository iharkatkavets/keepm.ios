//
//  KeePassCoreTestsConstants.swift
//  IKKeePassCore
//
//  Created by Igor Kotkovets on 8/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
@testable import KeePassCore

struct TestsConstants {
    static let kdbV4File = "kdbv4.kdbx"
    static let kdbV4WithEntryFile = "kdbv4-with-entry.kdbx"
    static let kdbV4IV: Data = Data(hex: "")!
    static var kdbV4Stream: KeePassCore.InputStream {
        let fileHandle = try! FileHandle(forReadingFrom: self.kdbV4Path)
        return FileInputStream(withFileHandle: fileHandle)
    }
    static var kdbV4Path: URL {
        return Bundle(for: KdbSignatureReaderTests.self).url(forResource: TestsConstants.kdbV4File, withExtension: nil)!
    }
    static var kdbV4WithEntryPath: URL {
        return Bundle(for: KdbSignatureReaderTests.self).url(forResource: TestsConstants.kdbV4WithEntryFile, withExtension: nil)!
    }
    static let kdbV4HeadersOffset: UInt64 = 12
    static var kdbV4Credentials: KdbCredentials {
        return KdbCredentials.password("12345678")
    }
    static var xmlV4Path: URL {
        return Bundle(for: KdbSignatureReaderTests.self).url(forResource: "kdb4payload-with-entry", withExtension: "xml")!
    }
    static var kdb4SalsaCipher: Data {
        return Data(base64Encoded: "")!
    }

    // online encoders
    // http://www.txtwizard.net/crypto   https://www.base64decode.org
    //
    static var aesInputStream: KeePassCore.InputStream {
        let url = Bundle(for: KdbSignatureReaderTests.self).url(forResource: "aescyphertext", withExtension: "txt")!
        let fileHandle = try! FileHandle(forReadingFrom: url)
        return FileInputStream(withFileHandle: fileHandle)
    }
    
    static var aesDecryptedData = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ac ante at libero interdum placerat. Integer in accumsan turpis, quis malesuada ligula. Fusce interdum augue ut est mollis pretium. Mauris molestie eros vitae diam consequat, ut interdum enim venenatis. Proin pellentesque velit id eros bibendum, non commodo dui tristique. Sed feugiat tincidunt arcu eget porta. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Duis eu lobortis tellus, ut sollicitudin augue. Cras pharetra tempor purus sit amet lobortis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam viverra tristique viverra. Mauris id neque et dui efficitur efficitur. Donec quis gravida mauris. Praesent sodales, est vitae dictum vestibulum, dolor nulla porta nisl, eu sodales metus nulla facilisis dolor. Quisque ac lobortis erat. Donec et purus leo. Donec ornare, metus ut viverra ultrices, eros tortor imperdiet lectus, nec aliquet nisl mauris a mi. Curabitur quis mattis nunc. Integer tristique ullamcorper egestas. Duis nibh mauris, consectetur quis efficitur rhoncus, lacinia ut dui. Morbi et nunc ac turpis vehicula porta at et nulla. Vestibulum in nibh quis diam sollicitudin scelerisque. Etiam sodales nunc ut magna rhoncus euismod. Nullam nec cursus arcu. Aliquam erat volutpat. Vivamus eros dui, lobortis eget porta sit amet, accumsan vitae quam. In sed nisi nisl. Praesent aliquam vehicula est, a vestibulum urna sagittis a. Suspendisse potenti. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Pellentesque fringilla odio suscipit ipsum condimentum placerat. Pellentesque interdum ullamcorper tempor. Praesent semper mauris malesuada rhoncus posuere. Duis suscipit lectus ut congue finibus. Nulla dictum convallis felis. Etiam non arcu eget felis tempus tempor. Nullam nibh eros, sagittis a tincidunt efficitur, dignissim eu nibh. Sed vitae leo massa. Pellentesque et arcu imperdiet, tincidunt augue at, commodo nulla. Ut tristique quis lectus sit amet hendrerit. Nullam suscipit, odio nec vulputate sodales, felis ipsum viverra mauris, at pharetra eros purus quis tellus. Sed gravida odio at suscipit sollicitudin. Sed a scelerisque nisi. Quisque tortor augue, cursus a tempus at, porttitor eget nisi. Phasellus elementum metus sapien, nec dapibus sem cursus luctus. Nulla congue a risus eget tincidunt. Mauris tincidunt fringilla sagittis. Donec scelerisque eros volutpat, rutrum tellus quis, rhoncus nisi. Quisque facilisis sagittis erat at venenatis. Mauris tristique suscipit dolor, quis volutpat lectus dignissim id. Quisque risus lectus, bibendum nec mi id, dignissim interdum mi. Cras at mattis diam, vel auctor quam. Nullam porttitor cursus faucibus. Sed sollicitudin dapibus erat quis imperdiet. Pellentesque sed turpis risus. Nulla dictum enim sed arcu suscipit gravida. Aliquam erat volutpat. Curabitur accumsan velit nisl, eget sodales justo volutpat non. Integer in malesuada turpis, ac tempor dui. Duis non ullamcorper nisi, at hendrerit lorem. Vivamus molestie risus at leo tincidunt, quis vestibulum dui scelerisque. Mauris vehicula orci sed magna placerat, eu accumsan leo gravida.".data(using: .utf8)!
    static var aesKey = Data(base64Encoded: "QmVsYXJ1czEyMzQ1Njc4OQ==")!
    static var aesIV = Data(base64Encoded: "TWluc2sxMjM0NTY3ODkwLQ==")!
    static var aesCypherData = Data(base64Encoded: "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")!
}

