//
//  KeePassDocument.swift
//  Pods
//
//  Created by Igor Kotkovets on 7/30/17.
//
//

import Foundation


class KeePassDocument {
    let fileInputStream: FileInputStream

    init(with url: URL) throws {
        let fileHandle = try FileHandle(forReadingFrom: url)
        let fileInputStream = FileInputStream(withFileHandle: fileHandle)
        self.fileInputStream = fileInputStream
    }

    // MARK: KeePassDocumentInterface
    func open(with password: String, key file: String?) {

    }
}
