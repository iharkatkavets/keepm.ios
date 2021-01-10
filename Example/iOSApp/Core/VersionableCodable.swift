//
//  VersionableCodable.swift
//  iOSApp
//
//  Created by igork on 6/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
// http://merowing.info/2020/06/adding-support-for-versioning-and-migration-to-your-codable-models./

import Foundation

public protocol Versionable: Codable {
    typealias Version = Int
    typealias MigrationClosure = (inout [String: Any]) -> Void
    typealias Migration = (to: Version, migration: MigrationClosure)

    /// Version of this type
    static var version: Version { get }

    static var migrations: [Migration] { get }

    /// Persisted Version of this type
    var version: Version { get }
}

struct VersionContainer: Codable {
    var version: Versionable.Version
}

public final class VersionableDecoder {
    public init() {
    }

    public func decode<T>(_ data: Data, type: T.Type) throws -> T where T: Versionable {
        let decoder = JSONDecoder()
        let serializedVersion = try decoder.decode(VersionContainer.self, from: data)

        if serializedVersion.version == type.version {
            return try decoder.decode(T.self, from: data)
        }

        var payload = try require(try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])

#if DEBUG
        let originalList = type.migrations
        let sorted = type.migrations.sorted(by: { $0.to < $1.to })
        assert(originalList.map { $0.to } == sorted.map { $0.to }, "\(type) migrations should be sorted by version")
#endif

        type
            .migrations
            .filter { serializedVersion.version < $0.to }
            .forEach {
                $0.migration(&payload)
                payload["version"] = $0.to
            }

        let data = try JSONSerialization.data(withJSONObject: payload as Any, options: [])
        return try decoder.decode(T.self, from: data)
    }
}

internal enum RequireError: Error {
    case isNil
}

/// Lifts optional or throws requested error if its nil
internal func require<T>(_ optional: T?, or error: Error = RequireError.isNil) throws -> T {
    guard let value = optional else {
        throw error
    }
    return value
}
