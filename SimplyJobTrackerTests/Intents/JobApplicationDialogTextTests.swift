//
//  JobApplicationDialogTextTests.swift
//  SimplyJobTrackerTests
//

import Testing
@testable import SimplyJobTracker

@Suite("JobApplicationDialogText")
struct JobApplicationDialogTextTests {

    @Test(
        "Siri's reply names the role and company it actually knows about",
        arguments: [
            ("Engineer", "Acme", "for Engineer at Acme"),
            ("", "Acme", "at Acme"),
            ("Engineer", "", "for Engineer")
        ]
    )
    func roleCompanyFragment(role: String, company: String, expected: String) async throws {
        #expect(JobApplicationDialogText.roleCompanyFragment(role: role, company: company) == expected)
    }

    @Test("Siri's reply omits the role/company clause entirely when neither is known")
    func roleCompanyFragmentEmpty() async throws {
        #expect(JobApplicationDialogText.roleCompanyFragment(role: "", company: "") == nil)
    }
}
