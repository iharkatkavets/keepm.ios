//
//  Optional+Extensions.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 7/20/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

extension Optional {
    public func orThrow(_ errorExpression: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            throw errorExpression()
        }
    }
}
