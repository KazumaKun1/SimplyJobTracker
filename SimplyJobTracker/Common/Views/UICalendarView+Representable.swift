//
//  UICalendarView+Representable.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/8/26.
//

import SwiftUI
import UIKit
import Foundation

enum CalendarSelectionMode {
    case single(Binding<Date?>)
    case multi(Binding<ClosedRange<Date>?>)
}

struct CalendarView: UIViewRepresentable {
    let mode: CalendarSelectionMode
    let validInterval: DateInterval
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.current
        calendarView.availableDateRange = validInterval
        
        configureBehavior(for: calendarView, context: context)
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.representable = self
        configureBehavior(for: uiView, context: context)
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UICalendarView, context: Context) -> CGSize? {
        let targetWidth = proposal.width ?? uiView.intrinsicContentSize.width
        return uiView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate, UICalendarSelectionMultiDateDelegate {
        var representable: CalendarView
        fileprivate var rangeStart: DateComponents?

        init(_ representable: CalendarView) {
            self.representable = representable
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if case .single(let binding) = representable.mode {
                binding.wrappedValue = dateComponents?.date
            }
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
            handleTap(dateComponents, on: selection)
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
            handleTap(dateComponents, on: selection)
        }

        private func handleTap(_ dateComponents: DateComponents, on selection: UICalendarSelectionMultiDate) {
            guard case .multi(let binding) = representable.mode else { return }
            let calendar = Calendar.current

            guard let tappedDate = dateComponents.date else { return }

            if let start = rangeStart, let startDate = start.date {
                let range = min(startDate, tappedDate)...max(startDate, tappedDate)
                selection.setSelectedDates(calendar.components(from: range), animated: true)
                binding.wrappedValue = range
                rangeStart = nil
            } else {
                selection.setSelectedDates([dateComponents], animated: true)
                rangeStart = dateComponents
                binding.wrappedValue = tappedDate...tappedDate
            }
        }
    }
}

private extension CalendarView {
    func configureBehavior(for calendarView: UICalendarView, context: Context) {
        let calendar = Calendar.current
        
        switch mode {
        case .single(let binding):
            let targetComponents = calendar.components(from: binding.wrappedValue)
            
            if let currentBehavior = calendarView.selectionBehavior as? UICalendarSelectionSingleDate {
                if currentBehavior.selectedDate != targetComponents {
                    currentBehavior.setSelected(targetComponents, animated: true)
                }
            } else {
                let singleBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
                singleBehavior.selectedDate = targetComponents
                calendarView.selectionBehavior = singleBehavior
            }
        case .multi(let binding):
            let targetComponentList = calendar.components(from: binding.wrappedValue)

            if binding.wrappedValue == nil {
                context.coordinator.rangeStart = nil
            }

            if let currentBehavior = calendarView.selectionBehavior as? UICalendarSelectionMultiDate {
                let selectedSet = Set(currentBehavior.selectedDates)
                if selectedSet != Set(targetComponentList) {
                    currentBehavior.setSelectedDates(targetComponentList, animated: true)
                }
            } else {
                let multiBehavior = UICalendarSelectionMultiDate(delegate: context.coordinator)
                multiBehavior.selectedDates = targetComponentList
                calendarView.selectionBehavior = multiBehavior
            }
        }
    }
}
