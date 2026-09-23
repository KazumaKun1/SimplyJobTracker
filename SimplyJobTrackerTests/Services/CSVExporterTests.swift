//
//  CSVExporterTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import Testing
@testable import SimplyJobTracker

@Suite("CSVExporter")
struct CSVExporterTests {

    private func makeRow(
        role: String = "",
        company: String = "",
        overallExperience: String = "",
        rating: Int? = nil,
        feeling: String = "",
        date: Date = Date(),
        isFavorite: Bool = false,
        interviewCount: Int = 0
    ) -> JobApplicationExportRow {
        let jobApplication = JobApplication(isFavorite: isFavorite)
        jobApplication.role = role
        jobApplication.company = company
        jobApplication.overallExperience = overallExperience
        jobApplication.rating = rating
        jobApplication.feeling = feeling
        jobApplication.date = date
        jobApplication.interviews = (0..<interviewCount).map { _ in Interview() }
        return JobApplicationExportRow(from: jobApplication)
    }

    @Test("an empty export still has a header row")
    func csvHeaderOnly() async throws {
        let csv = CSVExporter.makeCSV(from: [])

        #expect(csv == "Status,Role,Company,Date,Rating,Feeling,Overall Experience,Favorite,Interviews")
    }

    @Test("a single application exports as one correctly formatted row")
    func csvOneRow() async throws {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15))!
        let row = makeRow(
            role: "Engineer",
            company: "Acme",
            overallExperience: "Great",
            rating: 4,
            feeling: "Confident",
            date: date,
            isFavorite: false,
            interviewCount: 2
        )

        let csv = CSVExporter.makeCSV(from: [row])
        let lines = csv.components(separatedBy: "\n")

        #expect(lines.count == 2)
        #expect(lines[1] == "applied,Engineer,Acme,2026-03-15,4,Confident,Great,No,2")
    }

    @Test(
        "favorite status shows up as a plain Yes or No",
        arguments: [
            (true, "Yes"),
            (false, "No")
        ]
    )
    func csvFavoriteFlag(isFavorite: Bool, expected: String) async throws {
        let row = makeRow(isFavorite: isFavorite)

        let csv = CSVExporter.makeCSV(from: [row])

        #expect(csv.contains(",\(expected),0"))
    }

    @Test(
        "text starting with =, +, -, or @ is defused so spreadsheet apps don't run it as a formula",
        arguments: ["=", "+", "-", "@"]
    )
    func escapeFormulaPrefix(prefixCharacter: String) async throws {
        let row = makeRow(role: "\(prefixCharacter)cmd")

        let csv = CSVExporter.makeCSV(from: [row])

        #expect(csv.contains("'\(prefixCharacter)cmd"))
    }

    @Test(
        "text containing a comma, quote, or newline is safely quoted",
        arguments: [",", "\"", "\n", "\r"]
    )
    func escapeSpecialCharacter(specialCharacter: String) async throws {
        let role = "role\(specialCharacter)name"
        let row = makeRow(role: role)

        let csv = CSVExporter.makeCSV(from: [row])
        let expectedField = "\"" + role.replacingOccurrences(of: "\"", with: "\"\"") + "\""

        #expect(csv.contains(expectedField))
    }

    @Test("ordinary text is exported as-is, with no extra quoting")
    func escapePlainField() async throws {
        let row = makeRow(role: "Engineer")

        let csv = CSVExporter.makeCSV(from: [row])

        #expect(csv.contains(",Engineer,"))
        #expect(!csv.contains("\"Engineer\""))
    }

    @Test("text needing both formula protection and quoting gets both")
    func escapeFormulaAndComma() async throws {
        let row = makeRow(role: "=cmd,arg")

        let csv = CSVExporter.makeCSV(from: [row])

        #expect(csv.contains("\"'=cmd,arg\""))
    }

    @Test("the exported file's contents match what the CSV formatter produces")
    func writesReadableFile() async throws {
        let row = makeRow(role: "Engineer", company: "Acme")

        let url = try CSVExporter.writeToTemporaryFile([row])
        defer { try? FileManager.default.removeItem(at: url) }

        let contents = try String(contentsOf: url, encoding: .utf8)

        #expect(contents == CSVExporter.makeCSV(from: [row]))
    }

    @Test("the exported file is named with a .csv extension")
    func writesCSVExtension() async throws {
        let url = try CSVExporter.writeToTemporaryFile([])
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(url.pathExtension == "csv")
    }
}
