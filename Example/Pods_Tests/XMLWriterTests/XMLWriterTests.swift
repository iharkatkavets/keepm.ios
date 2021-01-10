//
//  XMLWriterTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class XMLWriterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateDocumentWithElement() {

        let doc = XMLDocument(rootElement: nil)
        let element = XMLElement(name: "Hello")
        doc.setRootElement(element)
        let xmlString = doc.xmlString
        XCTAssertNotNil(xmlString)
    }

    func testExample() {
        let keePassFile = Kdb4TreeTemplate.create()
        let dataOutputStream = DataOutputStream()
        let key = Data(count: 32)
        let randomGenerator = try! Salsa20Cipher(withKey: key, iv: RANDOM_GENERATOR_IV)
        let xmlWriter = XMLWriter(tree: keePassFile, outputStream: dataOutputStream, randomStream: randomGenerator)
        try! xmlWriter.write()
        let result = dataOutputStream.data
        print("")
    }

    func testWritingOriginKeePassFileStructure() {
        let keePassFile = Kdb.Tree()
        keePassFile.generator = "iOSAppKeePass"
        keePassFile.headerHash = Data(count: 32)
        keePassFile.group = Kdb.Group(name: "Root")


        let dataOutputStream = DataOutputStream()
        let key = Data(count: 32)
        let randomGenerator = try! Salsa20Cipher(withKey: key, iv: RANDOM_GENERATOR_IV)
        let xmlWriter = XMLWriter(tree: keePassFile, outputStream: dataOutputStream, randomStream: randomGenerator)
        try! xmlWriter.write()
        let data = dataOutputStream.data
        let xmlString = String(bytes: data, encoding: .utf8)
        let originString = ""
//        XCTAssertEqual(originString, xmlString)
    }
}
