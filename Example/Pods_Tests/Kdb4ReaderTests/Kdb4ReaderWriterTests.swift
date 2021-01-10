//
//  Kdb4ReaderTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import KeePassCore

class Kdb4ReaderWriterTests: XCTestCase {
    let credentials = KdbCredentials.password("SomePassword")

    func testThatsWriteHeaders() {
        let readParams = DatabaseParameters()
        readParams.transformRounds = 100000
        readParams.compressionAlgorithm = CompressionAlgorithm.gzip
        readParams.credentials = credentials
        let outStream = DataOutputStream()

        XCTAssertNoThrow2(try Kdb4Writer(cachedParameters: readParams)) { writer in
            XCTAssertNoThrow(try writer.writeHeaders(outStream))
            let inStream = DataInputStream(withData: outStream.data)
            let reader = Kdb4Reader(file: inStream)
            XCTAssertNoThrow2(try reader.readHeaders()) { headers in
                var header = headers.getHeader(with: .cipherId)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, AES_CIPHER_UUID)

                header = headers.getHeader(with: .compressionFlags)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, Data([0x01,0x00,0x00,0x00]))

                header = headers.getHeader(with: .masterSeed)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, writer.masterSeed)

                header = headers.getHeader(with: .transformSeed)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, writer.transformSeed)

                header = headers.getHeader(with: .transformRounds)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, Data([0xA0,0x86,0x01,0x00,0x00,0x00,0x00,0x00]))

                header = headers.getHeader(with: .encryptionIV)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, writer.encryptionIV)

                header = headers.getHeader(with: .protectedStreamKey)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, writer.protectedStreamKey)

                header = headers.getHeader(with: .streamStartBytes)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, writer.streamStartBytes)

                header = headers.getHeader(with: .innerRandomStreamId)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, Data([0x02,0x00,0x00,0x00]))

                header = headers.getHeader(with: .endEntry)
                XCTAssertNotNil(header)
                XCTAssertEqual(header!.data, Data([0x00,0x00,0x00,0x00]))
            }
        }
    }

    func testReadHeadersFromKDBXFile() {
        let url = Bundle(for: Kdb4ReaderWriterTests.self).url(forResource: "kdbv4headers", withExtension: "txt")!
        let fileHandle = try! FileHandle(forReadingFrom: url)
        let fileStream = FileInputStream(withFileHandle: fileHandle)
        let reader = Kdb4Reader(file: fileStream)
        XCTAssertNoThrow2(try reader.readHeaders()) { headers in
            var header = headers.getHeader(with: .cipherId)
            XCTAssertNotNil(header)
            XCTAssertEqual(header?.data, Data([0x31,0xc1,0xf2,0xe6,0xbf,0x71,0x43,0x50,0xbe,0x58,0x05,0x21,0x6a,0xfc,0x5a,0xff]))

            header = headers.getHeader(with: .compressionFlags)
            XCTAssertNotNil(header)
            XCTAssertEqual(header!.data, Data([0x01,0x00,0x00,0x00]))

            header = headers.getHeader(with: .masterSeed)
            XCTAssertNotNil(header)

            header = headers.getHeader(with: .transformSeed)
            XCTAssertNotNil(header)

            header = headers.getHeader(with: .transformRounds)
            XCTAssertNotNil(header)
            XCTAssertEqual(header?.data, Data([0x70,0x17,0x00,0x00,0x00,0x00,0x00,0x00]))
            XCTAssertNoThrow2(try reader.obtainTransformRounds(from: headers)) { rounds in
                XCTAssertEqual(6000, rounds)
            }
        }
    }

    func testReadWritedDatabase() {
        let writeParams = DatabaseParameters()
        writeParams.transformRounds = 100000
        writeParams.compressionAlgorithm = CompressionAlgorithm.gzip
        writeParams.credentials = credentials
        writeParams.tree = Kdb4TreeTemplate.create()
        let outStream = DataOutputStream()

        XCTAssertNoThrow2(try Kdb4Writer(cachedParameters: writeParams)) { writer in
            XCTAssertNoThrow(try writer.write(outStream))
            let inStream = DataInputStream(withData: outStream.data)

            
            let reader = Kdb4Reader(file: inStream)
            XCTAssertNoThrow2(try reader.readWithCredentials(credentials)) { readParams in

            }
        }
    }

}
