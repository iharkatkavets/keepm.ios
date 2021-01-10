//
//  XCTAssert+Extensions.swift
//  Pods_Tests
//
//  Created by Igor Kotkovets on 1/29/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

public func XCTAssertNoThrow2<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line, also validateResult: (T) throws -> Void) {
    func executeAndAssignResult(_ expression: @autoclosure () throws -> T, to: inout T?) rethrows {
        to = try expression()
    }
    var result: T?
    XCTAssertNoThrow(try executeAndAssignResult(expression(), to: &result), message, file: file, line: line)
    if let r = result {
        XCTAssertNoThrow(try validateResult(r), message, file: file, line: line)
    }
}

public func XCTAssertThrowsError<T, E: Error & Equatable>(_ expression: @autoclosure () throws -> T, expectedError: E, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertThrowsError(try expression(), message, file: file, line: line, { (error) in
        XCTAssertNotNil(error as? E, "\(error) is not \(E.self)", file: file, line: line)
        XCTAssertEqual(error as? E, expectedError, file: file, line: line)
    })
}
public func XCTAssertThrowsError<T, E: Error>(_ expression: @autoclosure () throws -> T, expectedErrorType: E.Type, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertThrowsError(try expression(), message, file: file, line: line, { (error) in
        XCTAssertNotNil(error as? E, "\(error) is not \(E.self)", file: file, line: line)
    })
}
