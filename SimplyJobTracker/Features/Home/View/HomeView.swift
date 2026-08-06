//
//  HomeView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/2/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    var viewModel: HomeViewModel
    
    @State private var filter: JobApplicationFilter = .init()

    /// How many status dots each day's activity column shows before collapsing the rest
    /// into a "+N" badge. Single source of truth — bump this to show more per day; the
    /// dot row and the overflow count both derive from it, so they can't drift apart.
    private let maxVisibleStatusesPerDay = 1

    @Query(sort: \JobApplication.date, order: .reverse)
    private var jobApplications: [JobApplication]
    
    private var filteredApplications: [JobApplication] {
        jobApplications.filter { application in
            if let status = filter.status, application.status != status {
                return false
            }
            
            switch filter.dateContainer.selection {
            case .none:
                break
            case .single(let date):
                if !Calendar.current.isDate(application.date, inSameDayAs: date) {
                    return false
                }
            case .range(let closedRange):
                if !closedRange.contains(application.date) {
                    return false
                }
            }

            return true
        }
    }
    
    private var statusCounts: [JobApplicationStatus: Int] {
        Dictionary(grouping: jobApplications, by: \.status)
            .mapValues(\.count)
    }
    
    private var filteredResultsCount: Int {
        filteredApplications.count
    }
    
    private var lastSevenDaysActivity: [DailyActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        let applicationsByDay = Dictionary(grouping: jobApplications) {
            calendar.startOfDay(for: $0.date)
        }

        return (-6...0).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else {
                return DailyActivity(date: .now, dayLabel: "N/A", statuses: [], excessCount: 0)
            }

            let label = date.formatted(.dateTime.weekday(.narrow)).uppercased()
            let applicationsForDay = applicationsByDay[date] ?? []
            let excessCount = max(0, applicationsForDay.count - maxVisibleStatusesPerDay)

            return DailyActivity(
                date: date,
                dayLabel: label,
                statuses: applicationsForDay.prefix(maxVisibleStatusesPerDay).map(\.status),
                excessCount: excessCount
            )
        }
    }
    
    var body: some View {
        ScreenContainer {
            VStack {
                HeaderView(text: "OVERVIEW")
                JobMetricsView(
                    activeFilter: $filter.status,
                    statusCount: statusCounts
                )

                HeaderView(text: "ACTIVITY")

                LastSevenDaysActivityView(activities: lastSevenDaysActivity, filter: $filter)
                
                
                HeaderView(text: "APPLICATION", height: 20) {
                    Button {
                        // TODO: - Implement the searchable sheet here
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                } trailingContent: {
                    FilterTagView(filter: $filter, numberOfItems: filteredResultsCount)
                }
                .padding(.vertical)

                if filteredApplications.isEmpty {
                    NoJobApplicationView(isFiltered: !jobApplications.isEmpty)
                } else {
                    JobApplicationList(jobApplications: filteredApplications)
                }
            }
            .padding(.horizontal)
            .background(.appBackground)
        } overlay: {
            AddButton {
                viewModel.createApplication()
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: JobApplication.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let coordinator = HomeCoordinator(modelContainer: container)
    
    HomeView(viewModel: coordinator.homeViewModel)
        .modelContainer(container)
}
