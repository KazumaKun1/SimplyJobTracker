//
//  CSVExporter.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/11/26.
//

import Foundation

enum CSVExporter {
    nonisolated private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    nonisolated static func makeCSV(from rows: [JobApplicationExportRow]) -> String {
        let header = ["Status", "Role", "Company", "Date", "Rating", "Feeling", "Overall Experience", "Favorite", "Interviews"]
        var lines = [header.map(escape).joined(separator: ",")]

        for row in rows {
            let fields = [
                row.status,
                row.role,
                row.company,
                dateFormatter.string(from: row.date),
                row.rating,
                row.feeling,
                row.overallExperience,
                row.isFavorite ? "Yes" : "No",
                String(row.interviewCount)
            ]
            lines.append(fields.map(escape).joined(separator: ","))
        }

        return lines.joined(separator: "\n")
    }

    nonisolated static func writeToTemporaryFile(_ rows: [JobApplicationExportRow]) throws -> URL {
        let csv = makeCSV(from: rows)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SimplyJobTracker-Export-\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString)")
            .appendingPathExtension("csv")

        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    nonisolated private static func escape(_ field: String) -> String {
        var field = field
        if let first = field.first, "=+-@".contains(first) {
            field = "'\(field)"
        }

        guard field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r") else {
            return field
        }

        return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
