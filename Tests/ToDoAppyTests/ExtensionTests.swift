//
//  ExtensionTests.swift
//  ToDo-Appy Tests
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Tests for extension utilities
//

import XCTest
@testable import ToDo_Appy

final class DateExtensionTests: XCTestCase {
    func testIsToday() {
        let today = Date()
        XCTAssertTrue(today.isToday)

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertFalse(tomorrow.isToday)
    }

    func testIsTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertTrue(tomorrow.isTomorrow)

        let today = Date()
        XCTAssertFalse(today.isTomorrow)
    }

    func testIsOverdue() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(yesterday.isOverdue)

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertFalse(tomorrow.isOverdue)
    }

    func testStartOfDay() {
        let date = Date()
        let startOfDay = date.startOfDay

        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testAddingDays() {
        let today = Date()
        let threeDaysLater = today.adding(days: 3)

        let daysDifference = Calendar.current.dateComponents([.day], from: today, to: threeDaysLater).day
        XCTAssertEqual(daysDifference, 3)
    }
}

final class StringExtensionTests: XCTestCase {
    func testIsBlank() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("   ".isBlank)
        XCTAssertTrue("\n\t  \n".isBlank)
        XCTAssertFalse("Hello".isBlank)
        XCTAssertFalse("  Hello  ".isBlank)
    }

    func testTrimmed() {
        XCTAssertEqual("  Hello World  ".trimmed, "Hello World")
        XCTAssertEqual("\nTest\t".trimmed, "Test")
        XCTAssertEqual("NoSpaces".trimmed, "NoSpaces")
    }

    func testTruncated() {
        let longString = "This is a very long string"
        XCTAssertEqual(longString.truncated(to: 10), "This is a ...")

        let shortString = "Short"
        XCTAssertEqual(shortString.truncated(to: 10), "Short")
    }

    func testExtractedPriority() {
        XCTAssertEqual("!".extractedPriority, .low)
        XCTAssertEqual("!!".extractedPriority, .medium)
        XCTAssertEqual("!!!".extractedPriority, .high)
        XCTAssertEqual("!!!!".extractedPriority, .urgent)
        XCTAssertNil("".extractedPriority)
    }

    func testHashtags() {
        let text = "This is a #test with #multiple #hashtags"
        let hashtags = text.hashtags
        XCTAssertEqual(hashtags.count, 3)
        XCTAssertTrue(hashtags.contains("test"))
        XCTAssertTrue(hashtags.contains("multiple"))
        XCTAssertTrue(hashtags.contains("hashtags"))
    }

    func testWordCount() {
        XCTAssertEqual("Hello World".wordCount, 2)
        XCTAssertEqual("One".wordCount, 1)
        XCTAssertEqual("".wordCount, 0)
        XCTAssertEqual("This is a test".wordCount, 4)
    }

    func testContainsIgnoringCase() {
        XCTAssertTrue("Hello World".containsIgnoringCase("hello"))
        XCTAssertTrue("Hello World".containsIgnoringCase("WORLD"))
        XCTAssertTrue("Hello World".containsIgnoringCase("Lo Wo"))
        XCTAssertFalse("Hello World".containsIgnoringCase("xyz"))
    }
}

final class ColorExtensionTests: XCTestCase {
    func testHexInitialization() {
        let color1 = Color(hex: "#FF5733")
        XCTAssertNotNil(color1)

        let color2 = Color(hex: "FF5733")
        XCTAssertNotNil(color2)

        let color3 = Color(hex: "F00")
        XCTAssertNotNil(color3)
    }

    func testPredefinedColors() {
        XCTAssertNotNil(Color.appBackground)
        XCTAssertNotNil(Color.appPrimary)
        XCTAssertNotNil(Color.appSuccess)
        XCTAssertNotNil(Color.appError)
    }
}
