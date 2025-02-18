#===-------------------------------------------------------------*- make -*-===#
#
# This source file is part of the Swift MMIO open source project
#
# Copyright (c) 2023 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
#
#===------------------------------------------------------------------------===#

CONFIGURATION = debug
SWIFT_FORMAT_CONFIGURATION := SupportingFiles/Tools/swift-format/.swift-format
.DEFAULT_GOAL = build
SKIP_LINT=

.PHONY: all lint format build test clean
all: lint build test

ifdef SKIP_LINT
lint:
	@echo "skipping linting..."
else
lint:
	@echo "linting..."
	@swift-format lint \
		--configuration $(SWIFT_FORMAT_CONFIGURATION) \
		--recursive \
		--strict \
		Package.swift Sources Tests
endif

format:
	@echo "formatting..."
	@swift-format format \
		--configuration $(SWIFT_FORMAT_CONFIGURATION) \
		--recursive \
		--in-place \
		Package.swift Sources Tests

build: lint
	@echo "building..."
	@swift build \
		--configuration $(CONFIGURATION) \
		--explicit-target-dependency-import-check error

test: build
	@echo "testing..."
	@swift test \
		--parallel \
		--explicit-target-dependency-import-check error
	@SWIFT_MMIO_FEATURE_INTERPOSABLE=1 swift test \
		--parallel \
		--explicit-target-dependency-import-check error

clean:
	@echo "cleaning..."
	@swift package clean
	@rm -rf .build
