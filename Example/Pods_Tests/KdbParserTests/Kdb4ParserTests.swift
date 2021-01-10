//
//  KdbParserTests.swift
//  Pods_Tests
//
//  Created by igork on 11/14/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class Kdb4ParserTests: XCTestCase {
    var fileStream: KeePassCore.InputStream!
    var generator: RandomGenerator!

    override func setUp() {
        fileStream = try! FileInputStream(withUrl: TestsConstants.xmlV4Path)
        generator = try! Salsa20Cipher(withKey: Data(hex: "572076e27ddc90ca659bb307411908e4080db92122c0c574bdc3c08da534e9d2")!,
                                          iv: RANDOM_GENERATOR_IV)
    }

    func testParsing() {
        XCTAssertNotNil(fileStream)
        let parser = XMLReader(withRandom: generator)
        let keePassFile = parser.parse(inputStream: fileStream)
        XCTAssertEqual("MiniKeePass", keePassFile?.generator)

        XCTAssertEqual("General", keePassFile?.group?.name)
        let subgroup = keePassFile?.group?.groups.first
        XCTAssertNotNil(subgroup)
        XCTAssertEqual("eMail", subgroup?.name)
        XCTAssertEqual(1, subgroup?.entries.count)
        let entry = subgroup?.entries.first
        XCTAssertNotNil(entry)
        XCTAssertEqual(5, entry?.strings.count)
    }

    func testParsingWithEntries() {
        let bundle = Bundle(for: Kdb4ParserTests.self)
        let url = bundle.url(forResource: "123456789_2", withExtension: "txt")
        XCTAssertNotNil(url)
        let fileStream = try! FileInputStream(withUrl: url!)
        XCTAssertNotNil(fileStream)
        let parser = XMLReader(withRandom: generator)
        let keePassFile = parser.parse(inputStream: fileStream)
        XCTAssertEqual("KeePassX", keePassFile?.generator)

        XCTAssertEqual(0, keePassFile?.group?.entries.count)
        let subgroups = keePassFile?.group?.groups
        XCTAssertEqual(2, subgroups?.count)
        let subgroup = subgroups?.first
        XCTAssertNotNil(subgroup)
        XCTAssertEqual("Recycle Bin", subgroups?.first?.name)
        XCTAssertEqual(1, subgroups?.first?.entries.count)

        XCTAssertEqual("FirstGroup", subgroups?.last?.name)
        XCTAssertEqual("Recycle Bin", subgroups?.first?.name)
        XCTAssertEqual(1, subgroup?.entries.count)
        let entry = subgroup?.entries.first
        XCTAssertNotNil(entry)
        XCTAssertEqual(5, entry?.strings.count)
    }

}
