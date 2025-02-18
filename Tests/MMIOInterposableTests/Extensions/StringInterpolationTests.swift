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

import XCTest

final class StringInterpolationTests: XCTestCase {
  func test_appendInterpolation_hexNibble() {
    XCTAssertEqual("\(hexNibble: 0x0)", "0")
    XCTAssertEqual("\(hexNibble: 0x1)", "1")
    XCTAssertEqual("\(hexNibble: 0x2)", "2")
    XCTAssertEqual("\(hexNibble: 0x3)", "3")
    XCTAssertEqual("\(hexNibble: 0x4)", "4")
    XCTAssertEqual("\(hexNibble: 0x5)", "5")
    XCTAssertEqual("\(hexNibble: 0x6)", "6")
    XCTAssertEqual("\(hexNibble: 0x7)", "7")
    XCTAssertEqual("\(hexNibble: 0x8)", "8")
    XCTAssertEqual("\(hexNibble: 0x9)", "9")
    XCTAssertEqual("\(hexNibble: 0xa)", "a")
    XCTAssertEqual("\(hexNibble: 0xb)", "b")
    XCTAssertEqual("\(hexNibble: 0xc)", "c")
    XCTAssertEqual("\(hexNibble: 0xd)", "d")
    XCTAssertEqual("\(hexNibble: 0xe)", "e")
    XCTAssertEqual("\(hexNibble: 0xf)", "f")
  }

  func test_appendInterpolation_hex() {
    // Int8
    XCTAssertEqual("\(hex: Int8.min)", "0x80")
    XCTAssertEqual("\(hex: Int8(-1))", "0xff")
    XCTAssertEqual("\(hex: Int8(0))", "0x00")
    XCTAssertEqual("\(hex: Int8(1))", "0x01")
    XCTAssertEqual("\(hex: Int8.max)", "0x7f")

    // Int16
    XCTAssertEqual("\(hex: Int16.min)", "0x8000")
    XCTAssertEqual("\(hex: Int16(-1))", "0xffff")
    XCTAssertEqual("\(hex: Int16(0))", "0x0000")
    XCTAssertEqual("\(hex: Int16(1))", "0x0001")
    XCTAssertEqual("\(hex: Int16.max)", "0x7fff")

    // Int32
    XCTAssertEqual("\(hex: Int32.min)", "0x8000_0000")
    XCTAssertEqual("\(hex: Int32(-1))", "0xffff_ffff")
    XCTAssertEqual("\(hex: Int32(0))", "0x0000_0000")
    XCTAssertEqual("\(hex: Int32(1))", "0x0000_0001")
    XCTAssertEqual("\(hex: Int32.max)", "0x7fff_ffff")

    // Int64
    XCTAssertEqual("\(hex: Int64.min)", "0x8000_0000_0000_0000")
    XCTAssertEqual("\(hex: Int64(-1))", "0xffff_ffff_ffff_ffff")
    XCTAssertEqual("\(hex: Int64(0))", "0x0000_0000_0000_0000")
    XCTAssertEqual("\(hex: Int64(1))", "0x0000_0000_0000_0001")
    XCTAssertEqual("\(hex: Int64.max)", "0x7fff_ffff_ffff_ffff")

    // UInt8
    XCTAssertEqual("\(hex: UInt8.min)", "0x00")
    XCTAssertEqual("\(hex: UInt8(1))", "0x01")
    XCTAssertEqual("\(hex: UInt8.max)", "0xff")

    // UInt16
    XCTAssertEqual("\(hex: UInt16.min)", "0x0000")
    XCTAssertEqual("\(hex: UInt16(1))", "0x0001")
    XCTAssertEqual("\(hex: UInt16.max)", "0xffff")

    // UInt32
    XCTAssertEqual("\(hex: UInt32.min)", "0x0000_0000")
    XCTAssertEqual("\(hex: UInt32(1))", "0x0000_0001")
    XCTAssertEqual("\(hex: UInt32.max)", "0xffff_ffff")

    // UInt64
    XCTAssertEqual("\(hex: UInt64.min)", "0x0000_0000_0000_0000")
    XCTAssertEqual("\(hex: UInt64(1))", "0x0000_0000_0000_0001")
    XCTAssertEqual("\(hex: UInt64.max)", "0xffff_ffff_ffff_ffff")
  }

  func test_appendInterpolation_hex_bytes() {
    // Int8
    XCTAssertEqual("\(hex: Int8.min, bytes: 1)", "0x80")
    XCTAssertEqual("\(hex: Int8(-1), bytes: 1)", "0xff")
    XCTAssertEqual("\(hex: Int8(0), bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: Int8(1), bytes: 1)", "0x01")
    XCTAssertEqual("\(hex: Int8.max, bytes: 1)", "0x7f")

    // Int16
    XCTAssertEqual("\(hex: Int16.min, bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: Int16(-1), bytes: 1)", "0xff")
    XCTAssertEqual("\(hex: Int16(0), bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: Int16(1), bytes: 1)", "0x01")
    XCTAssertEqual("\(hex: Int16.max, bytes: 1)", "0xff")

    // Int32
    XCTAssertEqual("\(hex: Int32.min, bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: Int32(-1), bytes: 1)", "0xff")
    XCTAssertEqual("\(hex: Int32(0), bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: Int32(1), bytes: 1)", "0x01")
    XCTAssertEqual("\(hex: Int32.max, bytes: 1)", "0xff")

    // Int64
    XCTAssertEqual("\(hex: Int64.min, bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: Int64(-1), bytes: 1)", "0xff")
    XCTAssertEqual("\(hex: Int64(0), bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: Int64(1), bytes: 1)", "0x01")
    XCTAssertEqual("\(hex: Int64.max, bytes: 1)", "0xff")

    // UInt8
    XCTAssertEqual("\(hex: UInt8.min, bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: UInt8(1), bytes: 1)", "0x01")
    XCTAssertEqual("\(hex: UInt8.max, bytes: 1)", "0xff")

    // UInt16
    XCTAssertEqual("\(hex: UInt16.min, bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: UInt16(1), bytes: 1)", "0x01")
    XCTAssertEqual("\(hex: UInt16.max, bytes: 1)", "0xff")

    // UInt32
    XCTAssertEqual("\(hex: UInt32.min, bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: UInt32(1), bytes: 1)", "0x01")
    XCTAssertEqual("\(hex: UInt32.max, bytes: 1)", "0xff")

    // UInt64
    XCTAssertEqual("\(hex: UInt64.min, bytes: 1)", "0x00")
    XCTAssertEqual("\(hex: UInt64(1), bytes: 1)", "0x01")
    XCTAssertEqual("\(hex: UInt64.max, bytes: 1)", "0xff")
  }
}
