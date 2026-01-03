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

    var currentDate = startDate
    let calendar = Calendar.gmt

    while currentDate < endDate {
        let dateStr = dateFormatter.string(from: currentDate)
        let weekdayStr = weekdayFormatter.string(from: currentDate)
        let isWeekend = CalUtil.isWeekend(date: currentDate)
        let dateKey = currentDate.cropTime()

        if let events = eventsByDate[dateKey] {
            for event in events.sorted(by: { $0.startDate < $1.startDate }) {
                let start = timeFormatter.string(from: event.startDate)
                let end = timeFormatter.string(from: event.endDate)
                let typeStr = formatWorkTypeForCSV(event.type)

                var duration = event.endDate.timeIntervalSince(event.startDate) / 3600
                if removeLunchBreak && (event.type == .office || event.type == .homeOffice) && duration > 6 {
                    duration -= 0.5
                }

                let hoursStr = String(format: "%.2f", duration)
                lines.append("\(dateStr),\(weekdayStr),\(start),\(end),\(typeStr),\(hoursStr)")
            }
        } else {
            let typeStr = isWeekend ? "Weekend" : "No Entry"
            lines.append("\(dateStr),\(weekdayStr),,,\(typeStr),")
        }

        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
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
