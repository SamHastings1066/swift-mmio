//===----------------------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift MMIO open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import SwiftSyntax
import SwiftSyntaxMacros
import XCTest

@testable import MMIOMacros

struct ExpressibleByExprSyntaxMacro: MMIOArgumentParsingMacro {
  mutating func update(
    label: String,
    from expression: ExprSyntax,
    in context: MacroContext<some ParsableMacro, some MacroExpansionContext>
  ) throws {
    fatalError()
  }
}

// swift-format-ignore: AlwaysUseLowerCamelCase
func XCTAssertParse<Value>(
  expression: ExprSyntax,
  expected: Value?,
  file: StaticString = #filePath,
  line: UInt = #line
) where Value: ExpressibleByExprSyntax, Value: Equatable {
  do {
    let context = MacroContext.makeSuppressingDiagnostics(
      ExpressibleByExprSyntaxMacro.self)
    let actual = try Value(expression: expression, in: context)
    XCTAssertEqual(expected, actual, file: file, line: line)
  } catch {
    XCTFail("Unexpected error: \(error)", file: file, line: line)
  }
}

// swift-format-ignore: AlwaysUseLowerCamelCase
func XCTAssertParseBitFieldTypeProjection(
  expression: ExprSyntax,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  let base = expression.as(MemberAccessExprSyntax.self)?.base
  XCTAssertParse(
    expression: expression,
    expected: base.map { BitFieldTypeProjection(expression: $0) },
    file: file,
    line: line)
}

// swift-format-ignore: AlwaysUseLowerCamelCase
func XCTAssertNoParse<Value>(
  expression: ExprSyntax,
  as _: Value.Type,
  file: StaticString = #filePath,
  line: UInt = #line
) where Value: ExpressibleByExprSyntax {
  do {
    let context = MacroContext.makeSuppressingDiagnostics(
      ExpressibleByExprSyntaxMacro.self)
    let actual = try Value(expression: expression, in: context)
    XCTFail("Expected error, but got: \(actual)", file: file, line: line)
  } catch {
    XCTAssert(error is ExpansionError, file: file, line: line)
  }
}

final class ExpressibleByExprSyntaxTests: XCTestCase {
  func test_exprSyntax() throws {
    let expression: ExprSyntax = "Bool.self"
    XCTAssertParse(expression: expression, expected: expression)
  }

  func test_int() throws {
    XCTAssertParse(expression: "0b1_1110_0010_0100_0000", expected: 123456)
    XCTAssertParse(expression: "0o361_100", expected: 123456)
    XCTAssertParse(expression: "123456", expected: 123456)
    XCTAssertParse(expression: "0x0001_e240", expected: 123456)

    XCTAssertNoParse(expression: "1 + 1", as: Int.self)
    // This could be made to work, but its a slippery slope to becoming an
    // arbitrary in expression evaluator, so for now parens are banned.
    XCTAssertNoParse(expression: "(1234)", as: Int.self)
  }

  func test_rangeInt() throws {
    XCTAssertParse(expression: "0..<1", expected: 0..<1)
    XCTAssertParse(expression: "0 ..< 1", expected: 0..<1)

    XCTAssertNoParse(expression: "1..<0", as: Range<Int>.self)
    XCTAssertNoParse(expression: "0...1", as: Range<Int>.self)
    XCTAssertNoParse(expression: "(0)..<1", as: Range<Int>.self)
    XCTAssertNoParse(expression: "0..<(1)", as: Range<Int>.self)
    XCTAssertNoParse(expression: "(0)..<(1)", as: Range<Int>.self)
  }

  func test_bitWidth() throws {
    XCTAssertParse(expression: "8", expected: BitWidth(value: 8))
    XCTAssertParse(expression: "16", expected: BitWidth(value: 16))
    XCTAssertParse(expression: "32", expected: BitWidth(value: 32))
    XCTAssertParse(expression: "64", expected: BitWidth(value: 64))

    XCTAssertNoParse(expression: "7", as: BitWidth.self)
  }

  func test_bitFieldTypeProjection() throws {
    XCTAssertParseBitFieldTypeProjection(expression: "Bool.self")
    XCTAssertParseBitFieldTypeProjection(expression: "Swift.Bool.self")
    XCTAssertParseBitFieldTypeProjection(expression: "Array<Int>.self")
    XCTAssertParseBitFieldTypeProjection(expression: "Swift.Array<Int>.self")

    XCTAssertNoParse(expression: "Bool", as: BitFieldTypeProjection.self)
    XCTAssertNoParse(expression: "1", as: BitFieldTypeProjection.self)
  }
}
