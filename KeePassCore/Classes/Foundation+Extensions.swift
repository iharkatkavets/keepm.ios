//
//  Foundation+Extensions.swift
//  Pods
//
//  Created by Igor Kotkovets on 1/2/18.
//

import Foundation

extension UUID {
    init(uuidData data: Data) {
        let uuidt = data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> uuid_t in
            let uuidt = uuid_t(bytes[00], bytes[01], bytes[02], bytes[03],
                               bytes[04], bytes[05], bytes[06], bytes[07],
                               bytes[08], bytes[09], bytes[10], bytes[11],
                               bytes[12], bytes[13], bytes[14], bytes[15])
            return uuidt
        }
        self.init(uuid: uuidt)
    }
}
