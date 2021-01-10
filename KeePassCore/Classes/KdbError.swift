//
//  KdbError.swift
//  KeePassCore
//
//  Created by Igor Kotkovets on 11/24/19.
//

import Foundation

enum KdbError: Error {
    case fileDoesNotExist
    case ivalidUrl
    case openFileError
    case invalidSignature
    case invalidHeader
    case readInvalidHeaderLength
    case invalid(header: HeaderIdentifier)
    case invalidPayload
    case invalidPassword
    case decrypt
    case cantCreateXMLDocument
    case cantWriteFile
}

enum KdbWriteError: Error {
    case cantCreateCommentHeader
}
