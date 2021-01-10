//
//  Constants.swift
//  KeePassCore
//
//  Created by Igor Kotkovets on 1/12/20.
//

import Foundation

let LOG_SUBSYSTEM = "KeePassCore"

let BASE_SIGNATURE_DATA     = Data([0x9A,0xA2,0xD9,0x03])
let BASE_SIGNATURE_UINT32   = UInt32(2594363651)
let KDB4_SIGNATURE          = Data([0xB5,0x4B,0xFB,0x67])
public let KDB2_SIGNATURE_UINT32   = UInt32(3041655655)
let KDB4_VERSION    = 0x00030001

let AES_CIPHER_UUID = Data([0x31, 0xC1, 0xF2, 0xE6,
                            0xBF, 0x71, 0x43, 0x50,
                            0xBE, 0x58, 0x05, 0x21,
                            0x6A, 0xFC, 0x5A, 0xFF])

let GZIP_COMPRESSION = UInt32(0x01)
let NONE_COMPRESSION = UInt32(0x00)


let RANDOM_STREAM_SALSA_20 = UInt32(0x02)

let RANDOM_GENERATOR_IV = Data([0xE8, 0x30, 0x09, 0x4B, 0x97, 0x20, 0x5D, 0x2A])

let KDB_GENERATOR = "iOSKdbX"

