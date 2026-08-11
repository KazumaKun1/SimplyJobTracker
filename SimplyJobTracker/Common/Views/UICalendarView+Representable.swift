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
        let targetWidth = proposal.width ?? 350
        let size = uiView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size
    }
    
    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate, UICalendarSelectionMultiDateDelegate {
        var representable: CalendarView
        
        init(_ representable: CalendarView) {
            self.representable = representable
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if case .single(let binding) = representable.mode {
                binding.wrappedValue = dateComponents?.date
            }
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
            processRange(from: selection)
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
            processRange(from: selection)
        }
        
        private func processRange(from selection: UICalendarSelectionMultiDate) {
            guard case .multi(let binding) = representable.mode else { return }
            
            let sortedDates = selection.selectedDates
                .compactMap { $0.date }
                .sorted()
            
            guard let firstDate = sortedDates.first, let lastDate = sortedDates.last else {
                binding.wrappedValue = nil
                return
            }
            
            binding.wrappedValue = firstDate...lastDate
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
