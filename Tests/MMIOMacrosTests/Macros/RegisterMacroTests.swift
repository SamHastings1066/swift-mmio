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
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import MMIOMacros

final class RegisterMacroTests: XCTestCase {
  typealias ErrorDiagnostic = MMIOMacros.ErrorDiagnostic<RegisterMacro>

  static let macros: [String: Macro.Type] = [
    "Register": RegisterMacro.self,
    "Reserved": ReservedMacro.self,
    "ReadWrite": ReadWriteMacro.self,
    "ReadOnly": ReadOnlyMacro.self,
    "WriteOnly": WriteOnlyMacro.self,
  ]
  static let indentationWidth = Trivia.spaces(2)

  // FIXME: test bitwidths parsing/allowed widths

  func test_decl_onlyStruct() {
    assertMacroExpansion(
      """
      @Register(bitWidth: 0x8) actor A {}
      @Register(bitWidth: 0x8) class C {}
      @Register(bitWidth: 0x8) enum E {}
      """,
      expandedSource: """
        actor A {}
        class C {}
        enum E {}
        """,
      diagnostics: [
        .init(
          message: ErrorDiagnostic.expectedDecl(StructDeclSyntax.self).message,
          line: 1,
          column: 26,
          // FIXME: https://github.com/apple/swift-syntax/pull/2213
          highlight: "actor "),
        .init(
          message: ErrorDiagnostic.expectedDecl(StructDeclSyntax.self).message,
          line: 2,
          column: 26,
          // FIXME: https://github.com/apple/swift-syntax/pull/2213
          highlight: "class "),
        .init(
          message: ErrorDiagnostic.expectedDecl(StructDeclSyntax.self).message,
          line: 3,
          column: 26,
          // FIXME: https://github.com/apple/swift-syntax/pull/2213
          highlight: "enum "),
      ],
      macros: Self.macros,
      indentationWidth: Self.indentationWidth)
  }

  func test_members_onlyVarDecls() {
    assertMacroExpansion(
      """
      @Register(bitWidth: 0x8)
      struct S {
        func f() {}
        class C {}
      }
      """,
      expandedSource: """
        struct S {
          func f() {}
          class C {}
        }

        extension S: RegisterValue {
        }
        """,
      diagnostics: [
        .init(
          message: ErrorDiagnostic.onlyMemberVarDecls().message,
          line: 3,
          column: 3,
          // FIXME: Improve this highlight
          highlight: "func f() {}"),
        .init(
          message: ErrorDiagnostic.onlyMemberVarDecls().message,
          line: 4,
          column: 3,
          // FIXME: Improve this highlight
          highlight: "class C {}"),

      ],
      macros: Self.macros,
      indentationWidth: Self.indentationWidth)
  }

  func test_members_varDeclsAreAnnotated() {
    assertMacroExpansion(
      """
      @Register(bitWidth: 0x8)
      struct S {
        var v1: Int
        @OtherAttribute var v2: Int
      }
      """,
      expandedSource: """
        struct S {
          var v1: Int
          @OtherAttribute var v2: Int
        }

        extension S: RegisterValue {
        }
        """,
      diagnostics: [
        .init(
          message: ErrorDiagnostic.expectedMemberAnnotatedWithOneOf(bitFieldMacros).message,
          line: 3,
          column: 3,
          highlight: "var v1: Int"),
        .init(
          message: ErrorDiagnostic.expectedMemberAnnotatedWithOneOf(bitFieldMacros).message,
          line: 4,
          column: 3,
          highlight: "@OtherAttribute var v2: Int"),
      ],
      macros: Self.macros,
      indentationWidth: Self.indentationWidth)
  }

  func test_expansion_noFields() {
    // FIXME: see expanded source formatting
    assertMacroExpansion(
      """
      @Register(bitWidth: 0x8)
      struct S {}
      """,
      expandedSource: """
        struct S {

          private init() {
            fatalError()
          }

          private var _never: Never

          struct Raw: RegisterValueRaw {
            typealias Value = S
            typealias Storage = UInt8
            var storage: Storage
            init(_ storage: Storage) {
              self.storage = storage
            }
            init(_ value: Value.ReadWrite) {
              self.storage = value.storage
            }

          }

          typealias Read = ReadWrite

          typealias Write = ReadWrite

          struct ReadWrite: RegisterValueRead, RegisterValueWrite {
            typealias Value = S
            var storage: UInt8
            init(_ value: ReadWrite) {
              self.storage = value.storage
            }
            init(_ value: Raw) {
              self.storage = value.storage
            }

          }}

        extension S: RegisterValue {
        }
        """,
      macros: Self.macros,
      indentationWidth: Self.indentationWidth)
  }

  func test_expansion_noTypedFields() {
    // FIXME: see expanded source formatting
    assertMacroExpansion(
      """
      @Register(bitWidth: 0x8)
      struct S {
        @ReadWrite(bits: 0..<1)
        var v1: V1
        @Reserved(bits: 1..<2)
        var v2: V2
      }
      """,
      expandedSource: """
        struct S {
          @available(*, unavailable)
          var v1: V1 {
            get {
              fatalError()
            }
          }
          @available(*, unavailable)
          var v2: V2 {
            get {
              fatalError()
            }
          }

          private init() {
            fatalError()
          }

          private var _never: Never

          enum V1: ContiguousBitField {
            typealias Storage = UInt8
            static let bitRange = 0 ..< 1
          }

          enum V2: ContiguousBitField {
            typealias Storage = UInt8
            static let bitRange = 1 ..< 2
          }

          struct Raw: RegisterValueRaw {
            typealias Value = S
            typealias Storage = UInt8
            var storage: Storage
            init(_ storage: Storage) {
              self.storage = storage
            }
            init(_ value: Value.ReadWrite) {
              self.storage = value.storage
            }
            var v1: UInt8 {
              @inlinable @inline(__always) get {
                V1.extract(from: self.storage)
              }
              @inlinable @inline(__always) set {
                V1.insert(newValue, into: &self.storage)
              }
            }
            var v2: UInt8 {
              @inlinable @inline(__always) get {
                V2.extract(from: self.storage)
              }
              @inlinable @inline(__always) set {
                V2.insert(newValue, into: &self.storage)
              }
            }
          }

          typealias Read = ReadWrite

          typealias Write = ReadWrite

          struct ReadWrite: RegisterValueRead, RegisterValueWrite {
            typealias Value = S
            var storage: UInt8
            init(_ value: ReadWrite) {
              self.storage = value.storage
            }
            init(_ value: Raw) {
              self.storage = value.storage
            }

          }
        }

        extension S: RegisterValue {
        }
        """,
      macros: Self.macros,
      indentationWidth: Self.indentationWidth)
  }

  func test_expansion_symmetric() {
    assertMacroExpansion(
      """
      @Register(bitWidth: 0x8)
      struct S {
        @ReadWrite(bits: 0..<1, as: Bool.self)
        var v1: V1
        @Reserved(bits: 1..<2)
        var v2: V2
      }
      """,
      expandedSource: """
        struct S {
          @available(*, unavailable)
          var v1: V1 {
            get {
              fatalError()
            }
          }
          @available(*, unavailable)
          var v2: V2 {
            get {
              fatalError()
            }
          }

          private init() {
            fatalError()
          }

          private var _never: Never

          enum V1: ContiguousBitField {
            typealias Storage = UInt8
            static let bitRange = 0 ..< 1
          }

          enum V2: ContiguousBitField {
            typealias Storage = UInt8
            static let bitRange = 1 ..< 2
          }

          struct Raw: RegisterValueRaw {
            typealias Value = S
            typealias Storage = UInt8
            var storage: Storage
            init(_ storage: Storage) {
              self.storage = storage
            }
            init(_ value: Value.ReadWrite) {
              self.storage = value.storage
            }
            var v1: UInt8 {
              @inlinable @inline(__always) get {
                V1.extract(from: self.storage)
              }
              @inlinable @inline(__always) set {
                V1.insert(newValue, into: &self.storage)
              }
            }
            var v2: UInt8 {
              @inlinable @inline(__always) get {
                V2.extract(from: self.storage)
              }
              @inlinable @inline(__always) set {
                V2.insert(newValue, into: &self.storage)
              }
            }
          }

          typealias Read = ReadWrite

          typealias Write = ReadWrite

          struct ReadWrite: RegisterValueRead, RegisterValueWrite {
            typealias Value = S
            var storage: UInt8
            init(_ value: ReadWrite) {
              self.storage = value.storage
            }
            init(_ value: Raw) {
              self.storage = value.storage
            }
            var v1: Bool {
              @inlinable @inline(__always) get {
                preconditionMatchingBitWidth(V1.self, Bool.self)
                return Bool(storage: self.raw.v1)
              }
              @inlinable @inline(__always) set {
                preconditionMatchingBitWidth(V1.self, Bool.self)
                self.raw.v1 = newValue.storage(Self.Value.Raw.Storage.self)
              }
            }
          }
        }

        extension S: RegisterValue {
        }
        """,
      macros: Self.macros,
      indentationWidth: Self.indentationWidth)
  }

  func test_expansion_discontiguous() {
    assertMacroExpansion(
      """
      @Register(bitWidth: 0x8)
      struct S {
        @ReadWrite(bits: 0..<1, 3..<4, as: UInt8.self)
        var v1: V1
      }
      """,
      expandedSource: """
        struct S {
          @available(*, unavailable)
          var v1: V1 {
            get {
              fatalError()
            }
          }

          private init() {
            fatalError()
          }

          private var _never: Never

          enum V1: DiscontiguousBitField {
            typealias Storage = UInt8
            static let bitRanges = [0 ..< 1, 3 ..< 4]
          }

          struct Raw: RegisterValueRaw {
            typealias Value = S
            typealias Storage = UInt8
            var storage: Storage
            init(_ storage: Storage) {
              self.storage = storage
            }
            init(_ value: Value.ReadWrite) {
              self.storage = value.storage
            }
            var v1: UInt8 {
              @inlinable @inline(__always) get {
                V1.extract(from: self.storage)
              }
              @inlinable @inline(__always) set {
                V1.insert(newValue, into: &self.storage)
              }
            }
          }

          typealias Read = ReadWrite

          typealias Write = ReadWrite

          struct ReadWrite: RegisterValueRead, RegisterValueWrite {
            typealias Value = S
            var storage: UInt8
            init(_ value: ReadWrite) {
              self.storage = value.storage
            }
            init(_ value: Raw) {
              self.storage = value.storage
            }
            var v1: UInt8 {
              @inlinable @inline(__always) get {
                preconditionMatchingBitWidth(V1.self, UInt8.self)
                return UInt8(storage: self.raw.v1)
              }
              @inlinable @inline(__always) set {
                preconditionMatchingBitWidth(V1.self, UInt8.self)
                self.raw.v1 = newValue.storage(Self.Value.Raw.Storage.self)
              }
            }
          }
        }

        extension S: RegisterValue {
        }
        """,
      macros: Self.macros,
      indentationWidth: Self.indentationWidth)
  }

  func test_expansion_asymmetric() {
    assertMacroExpansion(
      """
      @Register(bitWidth: 0x8)
      struct S {
        @ReadOnly(bits: 0..<1, as: Bool.self)
        var v1: V1
        @WriteOnly(bits: 1..<2, as: Bool.self)
        var v2: V2
      }
      """,
      expandedSource: """
        struct S {
          @available(*, unavailable)
          var v1: V1 {
            get {
              fatalError()
            }
          }
          @available(*, unavailable)
          var v2: V2 {
            get {
              fatalError()
            }
          }

          private init() {
            fatalError()
          }

          private var _never: Never

          enum V1: ContiguousBitField {
            typealias Storage = UInt8
            static let bitRange = 0 ..< 1
          }

          enum V2: ContiguousBitField {
            typealias Storage = UInt8
            static let bitRange = 1 ..< 2
          }

          struct Raw: RegisterValueRaw {
            typealias Value = S
            typealias Storage = UInt8
            var storage: Storage
            init(_ storage: Storage) {
              self.storage = storage
            }
            init(_ value: Value.Read) {
              self.storage = value.storage
            }
            init(_ value: Value.Write) {
              self.storage = value.storage
            }
            var v1: UInt8 {
              @inlinable @inline(__always) get {
                V1.extract(from: self.storage)
              }
              @inlinable @inline(__always) set {
                V1.insert(newValue, into: &self.storage)
              }
            }
            var v2: UInt8 {
              @inlinable @inline(__always) get {
                V2.extract(from: self.storage)
              }
              @inlinable @inline(__always) set {
                V2.insert(newValue, into: &self.storage)
              }
            }
          }

          struct Read: RegisterValueRead {
            typealias Value = S
            var storage: UInt8
            init(_ value: Raw) {
              self.storage = value.storage
            }
            var v1: Bool {
              @inlinable @inline(__always) get {
                preconditionMatchingBitWidth(V1.self, Bool.self)
                return Bool(storage: self.raw.v1)
              }
            }
          }

          struct Write: RegisterValueWrite {
            typealias Value = S
            var storage: UInt8
            init(_ value: Raw) {
              self.storage = value.storage
            }
            init(_ value: Read) {
              // FIXME: mask off bits
              self.storage = value.storage
            }
            var v2: Bool {
              @available(*, deprecated, message: "API misuse; read from write view returns the value to be written, not the value initially read.")
              @inlinable @inline(__always) get {
                preconditionMatchingBitWidth(V2.self, Bool.self)
                return Bool(storage: self.raw.v2)
              }
              @inlinable @inline(__always) set {
                preconditionMatchingBitWidth(V2.self, Bool.self)
                self.raw.v2 = newValue.storage(Self.Value.Raw.Storage.self)
              }
            }
          }
        }

        extension S: RegisterValue {
        }
        """,
      macros: Self.macros,
      indentationWidth: Self.indentationWidth)
  }
}
