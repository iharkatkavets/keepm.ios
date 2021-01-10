//
//  KdbV4Headers.swift
//  Pods
//
//  Created by Igor Kotkovets on 8/6/17.
//
//

import Foundation

struct KdbV4Headers {
    var list: [KdbHeader] = [KdbHeader]()

    var debugDescription: String {
        var str = "KdbV4Headers: \n"

        for header in list {
            str += "\n \(header.identifier) \(header.length) \(header.data.hexString())"
        }

        return str
    }

    init() {}

    mutating func add(header: KdbHeader) {
        list.append(header)
    }

    func getHeader(with identifier: HeaderIdentifier) -> KdbHeader? {
        return list.first { $0.identifier == identifier }
    }
}
