//
//  FilterView+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/12/26.
//

import SwiftUI

// MARK: - Favorite Section
extension FilterView {
    struct FavoriteSection: View {
        @Binding var isFavorite: Bool?

        private var isOn: Binding<Bool> {
            Binding(
                get: { isFavorite ?? false },
                set: { isFavorite = $0 ? true : nil }
            )
        }

        var body: some View {
            HStack {
                Image(systemName: isOn.wrappedValue ? "star.fill" : "star")
                    .foregroundStyle(isOn.wrappedValue ? Color.yellow : .primary)
                Spacer()
                Toggle("Favorites only", isOn: isOn)
                    .tint(.yellow)
                    .fontWeight(isOn.wrappedValue ? .semibold : .regular)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(isOn.wrappedValue ? Color.yellow.opacity(0.2) : .cardBackground2)
            )
            .animation(.easeInOut(duration: 0.1), value: isOn.wrappedValue)
            .padding(.bottom)
        }
    }
}

// MARK: - Status Section
extension FilterView {
    struct StatusSection: View {
        var currentStatus: Binding<JobApplicationStatus?>

        private let statuses: [JobApplicationStatus?] = [nil] + JobApplicationStatus.allCases.map { $0 as JobApplicationStatus? }

        private var rows: [[JobApplicationStatus?]] {
            stride(from: 0, to: statuses.count, by: 2).map {
                Array(statuses[$0..<min($0 + 2, statuses.count)])
            }
        }

        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                HeaderView(text: "STATUS")

                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    ForEach(rows.indices, id: \.self) { rowIndex in
                        GridRow {
                            ForEach(rows[rowIndex], id: \.self) { status in
                                StatusButton(currentStatus: currentStatus, status: status)
                            }
                            
                            if rows[rowIndex].count < 2 {
                                Color.clear
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct StatusButton: View {
        @Binding var currentStatus: JobApplicationStatus?
        var status: JobApplicationStatus?
        
        var body: some View {
            Button {
                currentStatus = status
            } label: {
                Text(status?.title ?? "All")
                .font(.callout)
                .fontWeight(currentStatus == status ? .bold : .regular)
                .foregroundStyle(status?.color ?? .secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill((status?.color ?? .secondary).opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(status?.color ?? .secondary, lineWidth: 1)
                        .opacity(currentStatus == status ? 1 : 0)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(status?.title ?? "All")
            .accessibilityAddTraits(currentStatus == status ? [.isSelected] : [])
            .animation(.default, value: currentStatus)
        }
    }
}

// MARK: - Date Section
extension FilterView {
    struct DateSection: View {
        var container: Binding<DateContainer>

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HeaderView(text: "APPLIED WITHIN")
                DateSelectionView(container: container)
                if container.rangePreset.wrappedValue == .custom {
                    Group {
                        Divider()
                            .padding(.vertical)
                        DateRangeTypeSelectionView(container: container)
                    }
                }
            }
            .padding(.bottom)
        }
    }
    
    struct DateSelectionView: View {
        @Binding var container: DateContainer
        
        private let dateRangeSelections = DateRangeSelection.allCases
        
        private var rows: [[DateRangeSelection]] {
            stride(from: 0, to: dateRangeSelections.count, by: 2).map {
                Array(dateRangeSelections[$0..<min($0 + 2, dateRangeSelections.count)])
            }
        }
        
        var body: some View {
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(rows[rowIndex], id: \.self) { selection in
                            DateSelectionButton(selection: selection, currentSelection: container.rangePreset) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    container.selectPreset(selection)
                                }
                            }
                        }
                        
                        if rows[rowIndex].count < 2 {
                            Color.clear
                        }
                    }
                }
            }
        }
    }
    
    struct DateSelectionButton: View {
        let selection: DateRangeSelection
        let currentSelection: DateRangeSelection?
        
        let action: () -> Void
        var body: some View {
            Button {
                action()
            } label: {
                SelectionView(title: selection.title, isSelected: currentSelection == selection)
            }
        }
    }
    
    struct DateRangeTypeSelectionView: View {
        @Binding var container: DateContainer
        
        private var calendarMode: CalendarSelectionMode {
            container.isSelectionSingleDate ? .single($container.singleDate) : .multi($container.dateRange)
        }
        
        var body: some View {
            VStack {
                HStack {
                    Button {
                        container.selection = .single(Date())
                    } label: {
                        SelectionView(title: "Single Date", isSelected: container.isSelectionSingleDate)
                    }
                    Button {
                        container.selection = .range(Date().relativeRange(days: -1))
                    } label: {
                        SelectionView(title: "Multi Date", isSelected: !container.isSelectionSingleDate)
                    }
                }
                .padding(.bottom)
                
                CalendarView(mode: calendarMode, validInterval: .init(start: .distantPast, end: .distantFuture))
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 6)
                    )
            }
        }
    }
}

// MARK: - Common
extension FilterView {
    struct SelectionView: View {
        let title: String
        let isSelected: Bool
        
        var body: some View {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(isSelected ? .white : .gray)
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? .blue : .cardBackground2)
                )
        }
    }
    
    struct FilterHeader: View {
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            HStack {
                Text("Filters")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .padding()
                        .foregroundStyle(.primary)
                        .background(
                            Circle()
                                .foregroundStyle(.blue.opacity(0.1))
                        )
                }
            }
        }
    }
    
    struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

#Preview {
    FilterView(filter: .init(projectedValue: .constant(.init())))
}
