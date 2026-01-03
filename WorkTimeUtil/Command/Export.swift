import Foundation

func exportCSV(_ parameters: [String], calendar: CalendarManager) {
    let removeLunchBreak = getRemoveLunchBreak() ?? true

    for parameter in parameters {
        guard let (startDate, endDate) = parseDateParameter(parameter) else {
            print("Invalid command. Usage: worktimeutil export [W|W<n>[/<yy>]|M|M<n>[/<yy>]]")
            exit(1)
        }

        let workEvents = calendar.fetchEvents(startDate: startDate, endDate: endDate)
        let csv = generateCSV(workEvents: workEvents, startDate: startDate, endDate: endDate, removeLunchBreak: removeLunchBreak)
        print(csv)
    }
}

private func generateCSV(workEvents: [WorkEvent], startDate: Date, endDate: Date, removeLunchBreak: Bool) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = .gmt

    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    timeFormatter.timeZone = .gmt

    let weekdayFormatter = DateFormatter()
    weekdayFormatter.dateFormat = "EEE"
    weekdayFormatter.timeZone = .gmt

    // Group events by date
    var eventsByDate: [Date: [WorkEvent]] = [:]
    for event in workEvents {
        let dateKey = event.startDate.cropTime()
        eventsByDate[dateKey, default: []].append(event)
    }

    var lines: [String] = []
    lines.append("Date,Day,Start,End,Type,Hours")

    // Sort dates and only output days with entries
    let sortedDates = eventsByDate.keys.sorted()

    for dateKey in sortedDates {
        guard let events = eventsByDate[dateKey] else { continue }

        let dateStr = dateFormatter.string(from: dateKey)
        let weekdayStr = weekdayFormatter.string(from: dateKey)

        let sortedEvents = events.sorted(by: { $0.startDate < $1.startDate })

        // Calculate total hours for the day
        var totalHours: Double = 0
        for event in sortedEvents {
            var duration = event.endDate.timeIntervalSince(event.startDate) / 3600
            if removeLunchBreak && (event.type == .office || event.type == .homeOffice) && duration > 6 {
                duration -= 0.5
            }
            totalHours += duration
        }

        // Get start/end times and types from all events
        let start = timeFormatter.string(from: sortedEvents.first!.startDate)
        let end = timeFormatter.string(from: sortedEvents.last!.endDate)

        // Combine types if multiple different types exist
        let types = Set(sortedEvents.map { formatWorkTypeForCSV($0.type) })
        let typeStr = types.sorted().joined(separator: "/")

        let hoursStr = String(format: "%.2f", totalHours)
        lines.append("\(dateStr),\(weekdayStr),\(start),\(end),\(typeStr),\(hoursStr)")
    }

    return lines.joined(separator: "\n")
}

private func formatWorkTypeForCSV(_ type: WorkType) -> String {
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
