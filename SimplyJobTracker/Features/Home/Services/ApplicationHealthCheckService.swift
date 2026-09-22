//
//  ApplicationHealthCheckService.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/22/26.
//

import Foundation
import FoundationModels

enum ApplicationHealthCheckError: Error {
    case modelUnavailable
    case generationFailed
}

@available(iOS 26.0, *)
protocol ApplicationHealthCheckService {
    func assessHealth(for input: ApplicationHealthCheckInput) async throws -> ApplicationHealthAssessment
}

@available(iOS 26.0, *)
actor ApplicationHealthCheckServiceImpl: ApplicationHealthCheckService {
    func assessHealth(for input: ApplicationHealthCheckInput) async throws -> ApplicationHealthAssessment {
        guard case .available = SystemLanguageModel.default.availability else {
            throw ApplicationHealthCheckError.modelUnavailable
        }

        let session = LanguageModelSession(instructions: Self.instructions)
        do {
            let response = try await session.respond(
                to: Self.prompt(for: input),
                generating: ApplicationHealthAssessment.self
            )
            return response.content
        } catch {
            throw ApplicationHealthCheckError.generationFailed
        }
    }

    private nonisolated static var instructions: String {
        """
        You are a career-coaching assistant embedded in a job-application tracker app. \
        You will be given structured facts about one job application: its status, how long ago it \
        was applied to, and its interview history with days-since-each-interview.

        Your job is to judge the health of this application, not to restate the facts you were given. \
        Each request includes a precomputed "Recency signal" line - trust it as the primary indicator \
        of staleness rather than re-deriving it yourself from the day counts. A "brand new" recency \
        signal must never be described as stale or needing attention, even if no interviews are \
        scheduled yet and every other field is empty - a fresh application with no activity yet is normal, \
        not a red flag. Recent interview activity or a fast-moving status should read as thriving or steady.

        Write the summary and next action as forward-looking coaching guidance. Never restate input \
        fields back to the user (for example, never write something like "This application is for the \
        Engineer role at Acme" - the user can already see that on screen).

        Not every status is a "waiting for the other side" state. A status like "offer" is a decision \
        point for the applicant, not a waiting period - the next action should reflect that (e.g. \
        "Decide whether to accept" or "No outreach needed, it's your move now"), not a generic \
        follow-up suggestion that assumes the applicant is still waiting to hear back.
        """
    }

    private nonisolated static func prompt(for input: ApplicationHealthCheckInput) -> String {
        var lines = [
            "Status: \(input.status)",
            "Applied: \(input.daysSinceApplied) days ago",
            "Recency signal: \(recencySignal(for: input))"
        ]

        if input.interviews.isEmpty {
            lines.append("Interviews: none scheduled yet")
        } else {
            let daysSinceLastInterview = input.interviews[input.interviews.count - 1].daysSince
            lines.append("Interviews: \(input.interviews.count) total, most recent \(daysSinceLastInterview) days ago")
            for interview in input.interviews {
                var detail = "- \(interview.title ?? "Untitled interview"), \(interview.daysSince) days ago"
                if let description = interview.description {
                    detail += ": \(description)"
                }
                lines.append(detail)
            }
        }

        if let rating = input.rating {
            lines.append("Applicant's own rating: \(rating)/5")
        }
        if let feeling = input.feeling {
            lines.append("How it felt: \(feeling)")
        }
        if let notes = input.notes {
            lines.append("Notes: \(notes)")
        }

        return lines.joined(separator: "\n")
    }

    /// Precomputes an explicit recency bucket instead of leaving the model to infer meaning
    /// from a raw day count against a threshold buried in prose — the on-device model
    /// (a small, on-device model) is unreliable at that kind of numeric-threshold reasoning
    /// and will otherwise pattern-match sparse input to "stale" regardless of the actual date.
    private nonisolated static func recencySignal(for input: ApplicationHealthCheckInput) -> String {
        let daysSinceLastActivity = input.interviews.last?.daysSince ?? input.daysSinceApplied

        switch daysSinceLastActivity {
        case ..<7:
            return "brand new, well within a normal waiting period - do not classify as stale or needing attention"
        case 7..<14:
            return "recent, still within a normal waiting period"
        case 14..<30:
            return "aging, past a normal waiting period - lean toward needing attention"
        default:
            return "long overdue for any activity - lean toward stale"
        }
    }
}
