//
//  UUID+Extensions.swift
//  KeePassCore
//
//  Created by igork on 1/28/20.
//

import Foundation

extension UUID {
    static var zero: UUID {
        let uuid: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        let result = UUID(uuid: uuid)
        return result
    }
}
