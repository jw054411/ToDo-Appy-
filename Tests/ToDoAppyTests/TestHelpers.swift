//
//  TestHelpers.swift
//  ToDo-Appy Tests
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Test utilities and helpers for all agents
//

import XCTest
import CloudKit
@testable import ToDo_Appy

// MARK: - Mock Data Generators

struct MockDataGenerator {
    /// Generate a random task title
    static func randomTaskTitle() -> String {
        let titles = [
            "Buy groceries",
            "Finish project proposal",
            "Call mom",
            "Schedule dentist appointment",
            "Review pull requests",
            "Update documentation",
            "Plan weekend trip",
            "Clean apartment",
            "Pay bills",
            "Exercise"
        ]
        return titles.randomElement() ?? "Test Task"
    }

    /// Generate a random category name
    static func randomCategoryName() -> String {
        let categories = ["Personal", "Work", "Shopping", "Health", "Finance", "Home"]
        return categories.randomElement() ?? "Test Category"
    }

    /// Generate a random tag name
    static func randomTagName() -> String {
        let tags = ["urgent", "important", "later", "someday", "review", "waiting"]
        return tags.randomElement() ?? "test-tag"
    }

    /// Generate a random hex color
    static func randomHexColor() -> String {
        let colors = ["#FF5733", "#33FF57", "#3357FF", "#FF33F5", "#F5FF33", "#33FFF5"]
        return colors.randomElement() ?? "#000000"
    }

    /// Generate a random priority
    static func randomPriority() -> Priority {
        return Priority.allCases.randomElement() ?? .none
    }

    /// Generate a random date in the future
    static func randomFutureDate() -> Date {
        let daysToAdd = Int.random(in: 1...30)
        return Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
    }

    /// Generate a random date in the past
    static func randomPastDate() -> Date {
        let daysToSubtract = Int.random(in: 1...30)
        return Calendar.current.date(byAdding: .day, value: -daysToSubtract, to: Date()) ?? Date()
    }
}

// MARK: - Test Expectations

extension XCTestCase {
    /// Wait for async operation with timeout
    func waitForAsync(timeout: TimeInterval = 5.0, completion: @escaping () -> Void) {
        let expectation = self.expectation(description: "Async operation")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)
    }
}

// MARK: - CloudKit Test Helpers

struct CloudKitTestHelpers {
    /// Create a test CKRecord for Task
    static func createTestTaskRecord(id: String = UUID().uuidString) -> CKRecord {
        let recordID = CKRecord.ID(recordName: id, zoneID: testZoneID())
        let record = CKRecord(recordType: "CKTask", recordID: recordID)

        record["id"] = id
        record["title"] = "Test Task"
        record["isCompleted"] = 0
        record["createdAt"] = Date()
        record["updatedAt"] = Date()
        record["priority"] = 0
        record["isDeleted"] = 0
        record["isRecurring"] = 0
        record["hasReminder"] = 0

        return record
    }

    /// Create a test CKRecord for Category
    static func createTestCategoryRecord(id: String = UUID().uuidString) -> CKRecord {
        let recordID = CKRecord.ID(recordName: id, zoneID: testZoneID())
        let record = CKRecord(recordType: "CKCategory", recordID: recordID)

        record["id"] = id
        record["name"] = "Test Category"
        record["colorHex"] = "#FF5733"
        record["icon"] = "folder.fill"
        record["sortOrder"] = 0
        record["createdAt"] = Date()
        record["updatedAt"] = Date()
        record["isDeleted"] = 0

        return record
    }

    /// Create a test CKRecord for Tag
    static func createTestTagRecord(id: String = UUID().uuidString) -> CKRecord {
        let recordID = CKRecord.ID(recordName: id, zoneID: testZoneID())
        let record = CKRecord(recordType: "CKTag", recordID: recordID)

        record["id"] = id
        record["name"] = "test-tag"
        record["colorHex"] = "#3357FF"
        record["createdAt"] = Date()
        record["updatedAt"] = Date()
        record["isDeleted"] = 0

        return record
    }

    /// Get test zone ID
    static func testZoneID() -> CKRecordZone.ID {
        return CKRecordZone.ID(zoneName: "TasksZone", ownerName: CKCurrentUserDefaultName)
    }

    /// Get test container
    static func testContainer() -> CKContainer {
        return CKContainer(identifier: "iCloud.com.personal.todoappy")
    }
}

// MARK: - Assertions

extension XCTestCase {
    /// Assert two dates are approximately equal (within tolerance)
    func assertDatesEqual(_ date1: Date, _ date2: Date, tolerance: TimeInterval = 1.0, _ message: String = "") {
        let difference = abs(date1.timeIntervalSince(date2))
        XCTAssertLessThanOrEqual(difference, tolerance, message)
    }

    /// Assert string is not blank
    func assertNotBlank(_ string: String, _ message: String = "") {
        XCTAssertFalse(string.isBlank, message.isEmpty ? "String should not be blank" : message)
    }

    /// Assert string is blank
    func assertBlank(_ string: String, _ message: String = "") {
        XCTAssertTrue(string.isBlank, message.isEmpty ? "String should be blank" : message)
    }
}
