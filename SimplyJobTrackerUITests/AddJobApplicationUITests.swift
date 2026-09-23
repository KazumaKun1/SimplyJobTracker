//
//  AddJobApplicationUITests.swift
//  SimplyJobTrackerUITests
//

import XCTest

final class AddJobApplicationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTappingAddCreatesANewUntitledApplication() throws {
        let app = XCUIApplication()
        app.launch()

        let addButton = app.buttons["plus"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Expected the floating add button on Home")

        let untitledApplications = app.buttons.matching(
            NSPredicate(format: "label == %@", "Untitled Role at Untitled Company, Applied")
        )
        let countBefore = untitledApplications.count

        addButton.tap()

        let countAfterAdd = NSPredicate(format: "count == %d", countBefore + 1)
        expectation(for: countAfterAdd, evaluatedWith: untitledApplications, handler: nil)
        waitForExpectations(timeout: 5)
    }
}
