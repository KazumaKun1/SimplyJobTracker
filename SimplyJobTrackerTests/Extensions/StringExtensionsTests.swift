//
//  StringExtensionsTests.swift
//  SimplyJobTrackerTests
//

import Testing
@testable import SimplyJobTracker

@Suite("String?+Extensions")
@MainActor
struct StringExtensionsTests {

    @Test(
        "blank or missing text is treated as absent, while real text passes through untouched",
        arguments: [
            (Optional<String>.none, Optional<String>.none),
            (Optional("") as String?, Optional<String>.none),
            (Optional("Product Manager") as String?, Optional("Product Manager") as String?)
        ]
    )
    func nilIfEmpty(input: String?, expected: String?) async throws {
        #expect(input.nilIfEmpty == expected)
    }
}
