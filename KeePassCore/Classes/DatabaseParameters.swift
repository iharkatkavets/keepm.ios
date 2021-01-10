//
//  DatabaseParameters.swift
//  KeePassCore
//
//  Created by Igor Kotkovets on 2/1/20.
//

import Foundation

public class DatabaseParameters {
    public var fileVersionMinor: UInt16 = 0x0001
    public var fileVersionMajor: UInt16 = 0x0003
    public var credentials: KdbCredentials?
    public var compressionAlgorithm: CompressionAlgorithm = .gzip
    public var tree: Kdb.Tree?
    public var transformRounds: UInt64 = 100000

    public init() {}
}
