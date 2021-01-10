//
//  KdbConstants.swift
//  Pods
//
//  Created by Igor Kotkovets on 11/21/17.
//

import Foundation

struct Kdb4Signature {
    static let base = UInt32(bigEndian: 0x03D9A29A)
    static let kdbVersion = UInt32(bigEndian: 0x67FB4BB5)
}

struct Kdb3Signature {
    static let base = "0x03D9A29A"
    static let kdbVersion = "0x67FB4BB5"
}
