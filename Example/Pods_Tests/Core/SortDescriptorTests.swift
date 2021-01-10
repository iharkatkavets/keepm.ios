//
//  SortDescriptorTests.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class Human {
    let first: String
    let last: String
    let year: Int

    init(first: String, last: String, year: Int) {
        self.first = first
        self.last = last
        self.year = year
    }
}

extension Human: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\nHuman(first: \(first), last: \(last), year: \(year)"
    }
}

class TestDocument: NSObject {
    @objc dynamic var name: String
    @objc dynamic var isDir: Bool

    init(name: String, isDir: Bool) {
        self.name = name
        self.isDir = isDir
    }

    override var debugDescription: String {
        return "\nTestDocument(name: \(name), isDir: \(isDir))"
    }
}

//extension Document: CustomDebugStringConvertible {
//    override var debugDescription: String {
//        return "\nDocument(name: \(name), isDir: \(isDir)"
//    }
//}

class SortDescriptorTests: XCTestCase {
    var originPeople: [Human] {
        let h0 = Human(first: "Jo", last: "Smith", year: 1970)
        let h1 = Human(first: "Joe", last: "Smith", year: 1970)
        let h2 = Human(first: "Joe", last: "Smyth", year: 1970)
        let h3 = Human(first: "Joanne", last: "smith", year: 1985)
        let h4 = Human(first: "Joanne", last: "smith", year: 1970)
        let h5 = Human(first: "Robert", last: "Jones", year: 1970)
        let people = [h0,h1,h2,h3,h4,h5]
        return people
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testThatSortHumanByName() {
        let people = self.originPeople
        print(people)

        let sortedPeople = people.sorted { p0, p1 in
            let left =  [p0.last, p0.first]
            let right = [p1.last, p1.first]

            return left.lexicographicallyPrecedes(right) {
                $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
            }
        }
        print(sortedPeople)
    }

    func testSortByYear() {
        let people = self.originPeople
        print(people)

        let sortByYear: SortDescriptor<Human> = sortDescriptor(key: { $0.year }, <)
        let sorted = people.sorted(by: sortByYear)
        print(sorted)
    }

    func testSortByYear2() {
        let people = self.originPeople
        print(people)

        let sortByYear: SortDescriptor<Human> = sortDescriptor(key: { $0.year })
        let sorted = people.sorted(by: sortByYear)
        print(sorted)
    }

    func testSortByFirstName() {
        let people = self.originPeople
        print(people)

        let sortByFirstName: SortDescriptor<Human> = sortDescriptor(key: { $0.first }, String.localizedCaseInsensitiveCompare)
        let sorted = people.sorted(by: sortByFirstName)
        print(sorted)
    }

    func testByFirstLastYear() {
        let people = self.originPeople
        print(people)

        let sortByLastName: SortDescriptor<Human> = sortDescriptor(key: { $0.last }, String.localizedCaseInsensitiveCompare)
        let sortByFirstName: SortDescriptor<Human> = sortDescriptor(key: { $0.first }, String.localizedCaseInsensitiveCompare)
        let sortByYear: SortDescriptor<Human> = sortDescriptor(key: { $0.year })
        let combined: SortDescriptor<Human> = combine(
          sortDescriptors: [sortByLastName,sortByFirstName,sortByYear]
        )

        let sorted = people.sorted(by: combined)
        print(sorted)
    }



    let originDocs: [TestDocument] = [
        TestDocument(name: ".keepass.kdbx.lock", isDir: false),
        TestDocument(name: "ремонт", isDir: true),
        TestDocument(name: "Copy of AAct 3.9.5 Portable_pwd_1.zip", isDir: false),
        TestDocument(name: "keepass.kdbx", isDir: false),
        TestDocument(name: "GymM", isDir: false),
        TestDocument(name: "Штрафы", isDir: false),
        TestDocument(name: "Продажа", isDir: true),
        TestDocument(name: "Developer", isDir: true),
        TestDocument(name: "vwpolo", isDir: true),
        TestDocument(name: "windows-important", isDir: true),
        TestDocument(name: "keepass-21.05.2018.kdbx", isDir: false),
        TestDocument(name: "swagger.json", isDir: false),
        TestDocument(name: "Manual Memory Management (Swift) copy.key", isDir: false),
        TestDocument(name: "DDD", isDir: false),
        TestDocument(name: "english-25.05.17.w.12.txt", isDir: false),
        TestDocument(name: "водонагреватели.png", isDir: false),
        TestDocument(name: "Screen Shot 2017-05-19 at 12.10.14 PM.png", isDir: false),
        TestDocument(name: "Отдых", isDir: false),
        TestDocument(name: "Поздравления с 8 Марта", isDir: false),
        TestDocument(name: "Untitled spreadsheet", isDir: false),
        TestDocument(name: "english", isDir: true),
        TestDocument(name: "viber image.jpg", isDir: false),
        TestDocument(name: "macOS-important", isDir: true),
        TestDocument(name: "Clover Configurator (Vibrant Edition).zip", isDir: false),
        TestDocument(name: "Clover Configurator (Classic Edition).zip", isDir: false),
        TestDocument(name: "vpn-issue.zip", isDir: false),
        TestDocument(name: "Backup", isDir: true),
        TestDocument(name: "viper.zip", isDir: false),
        TestDocument(name: "customers-rcd-300.zip", isDir: false),
        TestDocument(name: "conax-custom-receiver.zip", isDir: false),
        TestDocument(name: "applications", isDir: true),
        TestDocument(name: "Home server open ports", isDir: false),
        TestDocument(name: "IMG_20160506_195144.jpg", isDir: false),
        TestDocument(name: "документы", isDir: true),
        TestDocument(name: "openvpn-macmini-oxagile.zip", isDir: false),
        TestDocument(name: "Screen Shot 2015-10-22 at 12.53.13 PM.png", isDir: false),
        TestDocument(name: "PaperArtist_2015-08-19_21-08-26.jpeg", isDir: false),
        TestDocument(name: "20150811_131437.jpg", isDir: false),
        TestDocument(name: "20150731_093126.jpg", isDir: false),
        TestDocument(name: "ios-widget-example.zip", isDir: false),
        TestDocument(name: "здоровье", isDir: true),
        TestDocument(name: "финансы", isDir: true),
        TestDocument(name: "newCert.p12", isDir: false),
        TestDocument(name: "Bookmarks", isDir: true),
        TestDocument(name: "touran", isDir: true),
        TestDocument(name: "IntelliJIDEA_ReferenceCard_Mac.pdf", isDir: false),
        TestDocument(name: "WVGZZZ1TZ6W202835 Volkswagen Touran 2006   VinDecoderz.com is the best online VIN decoding tool.png", isDir: false),
        TestDocument(name: "WVGZZZ1TZ6W202835 Volkswagen Touran 2006 - VinDecoderz.com is the best online VIN decoding tool.png", isDir: false),
        TestDocument(name: "touran_engine_bjb_bkc_bru_bls_bxe_bxf_rus_an.zip", isDir: false),
        TestDocument(name: "Авто туран", isDir: false),
        TestDocument(name: "link.txt", isDir: false),
        TestDocument(name: "Новый документ (2)", isDir: false),
        TestDocument(name: "DSL-2650U_1.0.17_1970.01.10.21.08.48_config.xml", isDir: false),
        TestDocument(name: "Doc_725d81f1e496449c82cdbbfd47f123d4.html", isDir: false),
        TestDocument(name: "Резюме.docx", isDir: false),
        TestDocument(name: "e63bd10982 (1).jpg", isDir: false),
        TestDocument(name: "books", isDir: true),
        TestDocument(name: "Emacs shortcuts", isDir: false),
        TestDocument(name: "Git - useful commands", isDir: false),
    ]

    let smallOriginDocs: [TestDocument] = [
        TestDocument(name: ".keepass.kdbx.lock", isDir: false),
        TestDocument(name: "ремонт", isDir: true),
        TestDocument(name: "Copy of AAct 3.9.5 Portable_pwd_1.zip", isDir: false),
        TestDocument(name: "keepass.kdbx", isDir: false),
        TestDocument(name: "GymM", isDir: false),
        TestDocument(name: "Продажа", isDir: true),
        TestDocument(name: "Developer", isDir: true),
        TestDocument(name: "vwpolo", isDir: true),
        TestDocument(name: "windows-important", isDir: true),
        TestDocument(name: "keepass-21.05.2018.kdbx", isDir: false),
        TestDocument(name: "Manual Memory Management (Swift) copy.key", isDir: false),
        TestDocument(name: "DDD", isDir: false),
        TestDocument(name: "english-25.05.17.w.12.txt", isDir: false),
        TestDocument(name: "Screen Shot 2017-05-19 at 12.10.14 PM.png", isDir: false),
        TestDocument(name: "english", isDir: true),
        TestDocument(name: "viber image.jpg", isDir: false),
        TestDocument(name: "macOS-important", isDir: true),
        TestDocument(name: "Clover Configurator (Vibrant Edition).zip", isDir: false),
        TestDocument(name: "Clover Configurator (Classic Edition).zip", isDir: false),
        TestDocument(name: "Backup", isDir: true),
        TestDocument(name: "viper.zip", isDir: false),
        TestDocument(name: "customers-rcd-300.zip", isDir: false),
        TestDocument(name: "conax-custom-receiver.zip", isDir: false),
        TestDocument(name: "applications", isDir: true),
        TestDocument(name: "Home server open ports", isDir: false),
        TestDocument(name: "IMG_20160506_195144.jpg", isDir: false),
        TestDocument(name: "документы", isDir: true),
        TestDocument(name: "openvpn-macmini-oxagile.zip", isDir: false),
        TestDocument(name: "Screen Shot 2015-10-22 at 12.53.13 PM.png", isDir: false),
        TestDocument(name: "PaperArtist_2015-08-19_21-08-26.jpeg", isDir: false),
        TestDocument(name: "20150811_131437.jpg", isDir: false),
        TestDocument(name: "20150731_093126.jpg", isDir: false),
        TestDocument(name: "ios-widget-example.zip", isDir: false),
        TestDocument(name: "здоровье", isDir: true),
        TestDocument(name: "финансы", isDir: true),
        TestDocument(name: "newCert.p12", isDir: false),
        TestDocument(name: "Bookmarks", isDir: true),
        TestDocument(name: "touran", isDir: true),
        TestDocument(name: "IntelliJIDEA_ReferenceCard_Mac.pdf", isDir: false),
        TestDocument(name: "Авто туран", isDir: false),
        TestDocument(name: "link.txt", isDir: false),
        TestDocument(name: "Новый документ (2)", isDir: false),
        TestDocument(name: "DSL-2650U_1.0.17_1970.01.10.21.08.48_config.xml", isDir: false),
        TestDocument(name: "Doc_725d81f1e496449c82cdbbfd47f123d4.html", isDir: false),
        TestDocument(name: "Резюме.docx", isDir: false),
        TestDocument(name: "e63bd10982 (1).jpg", isDir: false),
        TestDocument(name: "books", isDir: true),
        TestDocument(name: "Emacs shortcuts", isDir: false),
        TestDocument(name: "Git - useful commands", isDir: false),
    ]

    let smallSmallOriginDocs: [TestDocument] = [
        TestDocument(name: "applications", isDir: true),
        TestDocument(name: "conax-custom-receiver.zip", isDir: true)
    ]

    func testSortDocumentNames() {
        let isDirDescriptor = NSSortDescriptor(key: "isDir", ascending: false)
        let nameDescriptor = NSSortDescriptor(key: "name", ascending: true,
          selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sorted = (originDocs as NSArray).sortedArray(using: [isDirDescriptor, nameDescriptor])
        print(sorted)
    }

    func testUsingMineSort() {
        let sortByIsDir: SortDescriptor<TestDocument> = sortDescriptor(key: { $0.isDir }, ascending: false)
        let sortByName: SortDescriptor<TestDocument> = sortDescriptor(key: { $0.name }, ascending: true, String.localizedCaseInsensitiveCompare(_:))
        let common: SortDescriptor<TestDocument> = combine(sortDescriptors: [sortByIsDir, sortByName])
//        let common: SortDescriptor<TestDocument> = combine(sortDescriptors: [sortByName])
//        let common: SortDescriptor<TestDocument> = combine(sortDescriptors: [sortByIsDir])
        let sorted = originDocs.sorted(by: common)
        print(sorted)
    }

    func testUsingMineSortOnSmallSmallOriginDocs() {
        let sortByIsDir: SortDescriptor<TestDocument> = sortDescriptor(key: { $0.isDir }, ascending: false)
        let sortByName: SortDescriptor<TestDocument> = sortDescriptor(key: { $0.name }, ascending: true, String.localizedCaseInsensitiveCompare(_:))
        let common: SortDescriptor<TestDocument> = combine(sortDescriptors: [sortByIsDir, sortByName])
        let sorted = smallSmallOriginDocs.sorted(by: common)
        print(sorted)
    }

    func testUsingDefaultSort() {
            let sorted = originDocs.sorted(by: { lhs, rhs in
                if lhs.isDir && !rhs.isDir {
                    return true
                }
                else if !lhs.isDir && rhs.isDir {
                    return false
                }
                else {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
            })
            print(sorted)
        }

}
