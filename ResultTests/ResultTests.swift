//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class ResultTests: XCTestCase {
	func testMapTransformsSuccesses() {
		XCTAssertEqual(success.map(count) ?? 0, 7)
	}

	func testMapRewrapsFailures() {
		XCTAssertEqual(failure.map(count) ?? 0, 0)
	}


	// MARK: Errors

	func testErrorsIncludeTheSourceFile() {
		let file = __FILE__
		XCTAssertEqual(Result<(), NSError>.error().file ?? "", file)
	}

	func testErrorsIncludeTheSourceLine() {
		let (line, error) = (__LINE__, Result<(), NSError>.error())
		XCTAssertEqual(error.line ?? -1, line)
	}

	func testErrorsIncludeTheCallingFunction() {
		let function = __FUNCTION__
		XCTAssertEqual(Result<(), NSError>.error().function ?? "", function)
	}


	// MARK: Cocoa API idioms

	func testTryProducesFailuresForBooleanAPIWithErrorReturnedByReference() {
		let result = try { attempt(true, succeed: false, error: $0) }
		XCTAssertFalse(result ?? false)
		XCTAssertNotNil(result.error)
	}

	func testTryProducesFailuresForOptionalWithErrorReturnedByReference() {
		let result = try { attempt(1, succeed: false, error: $0) }
		XCTAssertEqual(result ?? 0, 0)
		XCTAssertNotNil(result.error)
	}

	func testTryProducesSuccessesForBooleanAPI() {
		let result = try { attempt(true, succeed: true, error: $0) }
		XCTAssertTrue(result ?? false)
		XCTAssertNil(result.error)
	}

	func testTryProducesSuccessesForOptionalAPI() {
		let result = try { attempt(1, succeed: true, error: $0) }
		XCTAssertEqual(result ?? 0, 1)
		XCTAssertNil(result.error)
	}
}


// MARK: - Fixtures

let success = Result<String, NSError>.success("success")
let failure = Result<String, NSError>.failure(NSError(domain: "com.antitypical.Result", code: 0xdeadbeef, userInfo: nil))


// MARK: - Helpers

func attempt<T>(value: T, #succeed: Bool, #error: NSErrorPointer) -> T? {
	if succeed {
		return value
	} else {
		error.memory = Result<(), NSError>.error()
		return nil
	}
}

extension NSError {
	var function: String? {
		return userInfo?[Result<(), NSError>.functionKey as NSString] as? String
	}
	
	var file: String? {
		return userInfo?[Result<(), NSError>.fileKey as NSString] as? String
	}

	var line: Int? {
		return userInfo?[Result<(), NSError>.lineKey as NSString] as? Int
	}
}


// MARK: - Imports

import Prelude
import Result
import XCTest
