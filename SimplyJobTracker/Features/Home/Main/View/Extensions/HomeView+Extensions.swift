//
//  HomeView+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/4/26.
//

import SwiftUI
import SwiftData

// MARK: - Activity View
extension HomeView {
    struct DailyActivity: Identifiable {
        let id = UUID()
        let date: Date
        let dayLabel: String
        let statuses: [JobApplicationStatus]
        let excessCount: Int
    }
    
    struct LastSevenDaysActivityView: View {
        let activities: [DailyActivity]
        let filter: Binding<JobApplicationFilter>
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("LAST 7 DAYS")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
                DailyActivityView(activities: activities, singleDate: filter.dateContainer.singleDate)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.cardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 4)
            )
        }
    }
    
    struct DailyActivityView: View {
        let activities: [DailyActivity]
        @Binding var singleDate: Date?
        
        var body: some View {
            HStack(spacing: 16) {
                ForEach(activities) { activity in
                    let isSelected = singleDate.map { Calendar.current.isDate(activity.date, inSameDayAs: $0) } ?? false
                    DailyActivityColumn(activity: activity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue.opacity(0.2))
                            .opacity(isSelected ? 0.4 : 0)
                    )
                    .onTapGesture {
                        singleDate = isSelected ? nil : activity.date
                    }
                }
            }
        }
    }
    
    struct DailyActivityColumn: View {
        let activity: DailyActivity
        
        var body: some View {
            VStack(spacing: 8) {
                Text(activity.dayLabel)
                    .font(.caption)
                    .foregroundStyle(.gray)
                ActivityDotView(activity: activity)
                .frame(height: 12)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    struct ActivityDotView: View {
        let activity: DailyActivity
        
        var body: some View {
            HStack(spacing: 4) {
                if activity.statuses.isEmpty {
                    EmptyDotView()
                } else {
                    DotsStatusView(activity: activity)
                }
            }
        }
    }
    
    struct EmptyDotView: View {
        var body: some View {
            Circle()
                .fill(.gray.opacity(0.2))
                .frame(width: 8, height: 8)
        }
    }
    
    struct DotsStatusView: View {
        let activity: DailyActivity
        
        var body: some View {
            Group {
                ForEach(Array(activity.statuses.enumerated()), id: \.offset) { _, status in
                    Circle()
                        .fill(status.color)
                        .frame(width: 10, height: 10)
                }
                if activity.excessCount > 0 {
                    Text("+\(activity.excessCount)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Current Filter Tags
extension HomeView {
    struct FilterTagView: View {
        var filter: Binding<JobApplicationFilter>
        let numberOfItems: Int

        var body: some View {
            HStack(spacing: 8) {
                StatusFilterTag(status: filter.status, numberOfItems: numberOfItems)
                DateFilterTag(container: filter.dateContainer)
            }
        }
    }

    struct StatusFilterTag: View {
        @Binding var status: JobApplicationStatus?
        let numberOfItems: Int

        var body: some View {
            if let status {
                FilterTagCapsule(text: "\(status.title) \(numberOfItems)", tint: status.color) {
                    self.status = nil
                }
            }
        }
    }

    struct DateFilterTag: View {
        var container: Binding<DateContainer>

        var body: some View {
            if container.singleDate.wrappedValue != nil {
                SingleDateTag(date: container.singleDate)
            } else if container.dateRange.wrappedValue != nil {
                DateRangeTag(range: container.dateRange)
            }
        }
    }

    struct SingleDateTag: View {
        @Binding var date: Date?

        var body: some View {
            if let date {
                FilterTagCapsule(text: date.formatted(.dateTime.month(.abbreviated).day())) {
                    self.date = nil
                }
            }
        }
    }

    struct DateRangeTag: View {
        @Binding var range: ClosedRange<Date>?

        var body: some View {
            if let range {
                FilterTagCapsule(
                    text: "\(range.lowerBound.formatted(.dateTime.month(.abbreviated).day())) – \(range.upperBound.formatted(.dateTime.month(.abbreviated).day()))"
                ) {
                    self.range = nil
                }
            }
        }
    }

    struct FilterTagCapsule: View {
        let text: String
        var tint: Color = .secondary
        let onClose: () -> Void

        var body: some View {
            HStack(spacing: 6) {
                Text(text)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .foregroundStyle(tint.opacity(0.2))
            )
        }
    }
}

// MARK: - Application List
extension HomeView {
    struct NoJobApplicationView: View {
        let isFiltered: Bool

        var body: some View {
            VStack(spacing: 8) {
                Spacer()
                Text(isFiltered ? "No matches for your filters" : "Oops! You have no job applications")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                if isFiltered {
                    Text("Try adjusting or clearing your filters")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding()
        }
    }
    
    struct JobApplicationList: View {
        let jobApplications: [JobApplication]
        let actionTapped: (JobApplication) -> Void
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(jobApplications) { application in
                    Button {
                        actionTapped(application)
                    } label: {
                        JobApplicationCard(application: application)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(application.role ?? "Untitled Role") at \(application.company ?? "Untitled Company"), \(application.status.title)")
                }
            }
            .padding(.bottom)
            .animation(.easeInOut(duration: 0.25), value: jobApplications.count)
            Spacer()
        }
    }
    
    struct JobApplicationCard: View {
        let application: JobApplication

        var body: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(application.status.title)
                        .foregroundStyle(application.status.color)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(application.status.color)
                                .opacity(0.2)
                        )
                    Text(application.role ?? "Untitled Role")
                        .font(.headline)
                    HStack {
                        Text(application.company ?? "Untitled Company")
                            .font(.subheadline)
                        if !application.interviews.isEmpty {
                            Text(" • ")
                            Text(application.interviews.fullDescription)
                        }
                    }
                }
                Spacer()
                Text(application.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .foregroundStyle(.cardBackground)
                    .shadow(color: .black.opacity(0.1),  radius: 6)
            )
        }
    }
}

// MARK: - Job Metrics View
extension HomeView {
    struct TileData: Identifiable {
        let id = UUID()
        let status: JobApplicationStatus
        let number: Int
    }
    
    struct MetricPage: Identifiable {
        let id: Int
        let tiles: [TileData]
    }
    
    struct JobMetricsView: View {
        @State private var currentPage = 0
        @Binding var activeFilter: JobApplicationStatus?
        let statusCount: [JobApplicationStatus: Int]
        
        private var pages: [MetricPage] {
            let primaryPage = MetricPage(id: 0, tiles: [
                TileData(status: .applied, number: statusCount[.applied] ?? 0),
                TileData(status: .interviewing, number: statusCount[.interviewing] ?? 0),
                TileData(status: .offer, number: statusCount[.offer] ?? 0)
            ])
            let secondaryPage = MetricPage(id: 1, tiles: [
                TileData(status: .rejected, number: statusCount[.rejected] ?? 0),
                TileData(status: .passed, number: statusCount[.passed] ?? 0)
            ])
            
            return [primaryPage, secondaryPage]
        }
        
        var body: some View {
            TabView(selection: $currentPage) {
                ForEach(pages) { page in
                    HStack {
                        ForEach(page.tiles) { tile in
                            TileView(number: tile.number, text: tile.status.title, color: tile.status.color)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(tile.status.color, lineWidth: 2)
                                        .opacity(activeFilter == tile.status ? 0.6 : 0)
                                )
                                .onTapGesture {
                                    activeFilter = activeFilter == tile.status ? nil : tile.status
                                }
                                .animation(.default, value: activeFilter)
                        }
                    }
                    .padding(.top, 5)
                    .tag(page.id)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: 135)
        }
    }
    
    struct TileView: View {
        let number: Int
        let text: String
        let color: Color
        
        var body: some View {
            VStack {
                Text("\(number)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(color.opacity(0.2))
            )
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.appBackground)
                    .shadow(color: .black.opacity(0.1), radius: 1)
            )
        }
    }
}

// MARK: - Floating Buttons
extension HomeView {
    struct FloatingButton: View {
        let image: String
        var backgroundColor: Color = .blue
        var imageTint: Color = .white
        var font: Font = .largeTitle
        
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Image(systemName: image)
                    .font(font)
                    .fontWeight(.bold)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(imageTint)
            }
            .tint(backgroundColor)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .shadow(radius: 2)
            .padding(.bottom, 10)
            .padding(.trailing, 10)
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
