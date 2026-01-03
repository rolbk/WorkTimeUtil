import Foundation

func calculateWorkHours(_ parameters: [String], calendar: CalendarManager, verbose: Bool) {
    let workHoursPerWeek = getWorkHoursPerWeek() ?? 38.5
    let removeLunchBreak = getRemoveLunchBreak() ?? true

    for parameter in parameters {
        guard let (startDate, endDate) = parseDateParameter(parameter) else {
            print("Invalid command. Usage: worktimeutil calculate [-v] [W|W<n>[/<yy>]|M|M<n>[/<yy>]]")
            exit(1)
        }

        let workEvents = calendar.fetchEvents(startDate: startDate, endDate: endDate)
        let shouldWork = calculateTargetWorkHours(startDate: startDate, endDate: endDate, workEvents: workEvents, workHoursPerWeek: workHoursPerWeek)
        let didWork = calculateActualWorkHours(startDate: startDate, endDate: endDate, workEvents: workEvents, removeLunchBreak: removeLunchBreak)

        print("For '\(parameter)':")

        if verbose {
            printVerboseTable(workEvents: workEvents, removeLunchBreak: removeLunchBreak)
        }

        print("Should Work: \(shouldWork.rounded(toDecimalPlaces: 2)) hours")
        print("Did Work: \(didWork.rounded(toDecimalPlaces: 2)) hours")
        print("")
    }
}

private func printVerboseTable(workEvents: [WorkEvent], removeLunchBreak: Bool) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = .gmt

    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    timeFormatter.timeZone = .gmt

    let sortedEvents = workEvents.sorted { $0.startDate < $1.startDate }

    // Print table header
    print("┌────────────┬───────┬───────┬────────────────┬─────────┐")
    print("│ Date       │ Start │ End   │ Type           │ Hours   │")
    print("├────────────┼───────┼───────┼────────────────┼─────────┤")

    var totalHours: Double = 0

    for event in sortedEvents {
        let date = dateFormatter.string(from: event.startDate)
        let start = timeFormatter.string(from: event.startDate)
        let end = timeFormatter.string(from: event.endDate)
        let typeStr = formatWorkType(event.type)

        var duration = event.endDate.timeIntervalSince(event.startDate) / 3600
        if removeLunchBreak && (event.type == .office || event.type == .homeOffice) && duration > 6 {
            duration -= 0.5
        }

        if event.isWork {
            totalHours += duration
        }

        let hoursStr = String(format: "%6.2f", duration)

        print("│ \(date) │ \(start) │ \(end) │ \(typeStr.padding(toLength: 14, withPad: " ", startingAt: 0)) │ \(hoursStr)h │")
    }

    print("├────────────┴───────┴───────┴────────────────┼─────────┤")
    print("│ Total Work Hours                            │ \(String(format: "%6.2f", totalHours))h │")
    print("└─────────────────────────────────────────────┴─────────┘")
    print("")
}

private func formatWorkType(_ type: WorkType) -> String {
    switch type {
    case .office: return "Office"
    case .homeOffice: return "Home Office"
    case .meeting: return "Meeting"
    case .companyEvent: return "Company Event"
    case .vacation: return "Vacation"
    case .holiday: return "Holiday"
    case .compensatory: return "Compensatory"
    case .sick: return "Sick"
    }
}

private func calculateActualWorkHours(startDate: Date, endDate: Date, workEvents: [WorkEvent], removeLunchBreak: Bool) -> TimeInterval {
    var totalDuration: TimeInterval = 0
    for workEvent in workEvents.filter({ $0.isWork }) {
        let duration = workEvent.endDate.timeIntervalSince(workEvent.startDate)
        totalDuration += duration

        if removeLunchBreak && (workEvent.type == .office || workEvent.type == .homeOffice) && duration > 6 * 3600 {
            totalDuration -= 0.5 * 3600
        }
    }

    return totalDuration / 3600
}

private func calculateTargetWorkHours(startDate: Date, endDate: Date, workEvents: [WorkEvent], workHoursPerWeek: TimeInterval) -> TimeInterval {
    var totalDuration: TimeInterval = 0
    var currentDate = startDate

    while currentDate <= endDate {
        // Check if current date is a weekend or holiday
        let calendar = Calendar.gmt
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        if dayOfWeek == 1 || dayOfWeek == 7 {
            // Weekend
        } else {
            // Work day
            let matchingEvents = workEvents.filter { $0.startDate <= currentDate && $0.endDate > currentDate }
            let isWorkDay = !matchingEvents.contains { $0.reducesTarget }
            if isWorkDay {
                totalDuration += workHoursPerWeek / 5.0
            }
        }

        // Move to the next day
        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
    }

    return totalDuration
}
