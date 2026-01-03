import XCTest
@testable import WorkTimeUtil

final class DateUtilTests: XCTestCase {

    // MARK: - Week Tests

    func testStartAndEndDatesForCurrentWeek() {
        let (start, end) = CalUtil.startAndEndDatesForCurrentWeek()
        let calendar = Calendar.gmt

        // End should be 6 days after start
        let daysBetween = calendar.dateComponents([.day], from: start, to: end).day
        XCTAssertEqual(daysBetween, 6, "Week should span 6 days")

        // Both dates should be in the same week
        let startWeek = calendar.component(.weekOfYear, from: start)
        let endWeek = calendar.component(.weekOfYear, from: end)
        XCTAssertEqual(startWeek, endWeek, "Start and end should be in the same week")
    }

    func testStartAndEndDatesForSpecificWeek() {
        let (start, _) = CalUtil.startAndEndDatesForWeek(week: 1, year: 2025)
        let calendar = Calendar.gmt

        let weekOfYear = calendar.component(.weekOfYear, from: start)
        XCTAssertEqual(weekOfYear, 1, "Should be week 1")

        let year = calendar.component(.yearForWeekOfYear, from: start)
        XCTAssertEqual(year, 2025, "Should be year 2025")
    }

    func testWeekWithTwoDigitYear() {
        let (start, _) = CalUtil.startAndEndDatesForWeek(week: 10, year: 25)
        let calendar = Calendar.gmt

        let year = calendar.component(.yearForWeekOfYear, from: start)
        XCTAssertEqual(year, 2025, "Two-digit year 25 should become 2025")
    }

    func testFutureWeekUsesPreviousYear() {
        // This test checks that if we're in week 1 and ask for week 52, we get the previous year
        let calendar = Calendar.gmt
        let now = Date()
        let currentWeek = calendar.component(.weekOfYear, from: now)
        let currentYear = calendar.component(.yearForWeekOfYear, from: now)

        // Request a week that's definitely in the future this year
        let futureWeek = currentWeek + 26 > 52 ? 52 : currentWeek + 26
        let (start, _) = CalUtil.startAndEndDatesForWeek(week: futureWeek, year: nil)

        let resultYear = calendar.component(.yearForWeekOfYear, from: start)

        if futureWeek > currentWeek {
            XCTAssertEqual(resultYear, currentYear - 1, "Future week without year should use previous year")
        }
    }

    // MARK: - Month Tests

    func testStartAndEndDatesForCurrentMonth() {
        let (start, end) = CalUtil.startAndEndDatesForCurrentMonth()
        let calendar = Calendar.gmt

        let startDay = calendar.component(.day, from: start)
        XCTAssertEqual(startDay, 1, "Month should start on day 1")

        // End should be start of next month
        let endDay = calendar.component(.day, from: end)
        XCTAssertEqual(endDay, 1, "End should be first day of next month")
    }

    func testStartAndEndDatesForSpecificMonth() {
        let (start, end) = CalUtil.startAndEndDatesForMonth(month: 3, year: 2025)
        let calendar = Calendar.gmt

        let month = calendar.component(.month, from: start)
        let year = calendar.component(.year, from: start)
        XCTAssertEqual(month, 3, "Should be March")
        XCTAssertEqual(year, 2025, "Should be 2025")

        let endMonth = calendar.component(.month, from: end)
        XCTAssertEqual(endMonth, 4, "End should be April")
    }

    func testMonthWithTwoDigitYear() {
        let (start, _) = CalUtil.startAndEndDatesForMonth(month: 6, year: 24)
        let calendar = Calendar.gmt

        let year = calendar.component(.year, from: start)
        XCTAssertEqual(year, 2024, "Two-digit year 24 should become 2024")
    }

    func testFutureMonthUsesPreviousYear() {
        let calendar = Calendar.gmt
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        // Request a month that's definitely in the future
        let futureMonth = currentMonth == 12 ? 12 : currentMonth + 6 > 12 ? 12 : currentMonth + 6
        let (start, _) = CalUtil.startAndEndDatesForMonth(month: futureMonth, year: nil)

        let resultYear = calendar.component(.year, from: start)

        if futureMonth > currentMonth {
            XCTAssertEqual(resultYear, currentYear - 1, "Future month without year should use previous year")
        }
    }

    // MARK: - Weekend Tests

    func testIsWeekendSaturday() {
        // Create a known Saturday: January 4, 2025
        let calendar = Calendar.gmt
        let saturday = calendar.date(from: DateComponents(year: 2025, month: 1, day: 4))!
        XCTAssertTrue(CalUtil.isWeekend(date: saturday), "Saturday should be a weekend")
    }

    func testIsWeekendSunday() {
        // Create a known Sunday: January 5, 2025
        let calendar = Calendar.gmt
        let sunday = calendar.date(from: DateComponents(year: 2025, month: 1, day: 5))!
        XCTAssertTrue(CalUtil.isWeekend(date: sunday), "Sunday should be a weekend")
    }

    func testIsNotWeekendMonday() {
        // Create a known Monday: January 6, 2025
        let calendar = Calendar.gmt
        let monday = calendar.date(from: DateComponents(year: 2025, month: 1, day: 6))!
        XCTAssertFalse(CalUtil.isWeekend(date: monday), "Monday should not be a weekend")
    }

    func testIsNotWeekendFriday() {
        // Create a known Friday: January 3, 2025
        let calendar = Calendar.gmt
        let friday = calendar.date(from: DateComponents(year: 2025, month: 1, day: 3))!
        XCTAssertFalse(CalUtil.isWeekend(date: friday), "Friday should not be a weekend")
    }

    // MARK: - Date Extension Tests

    func testCropTime() {
        let calendar = Calendar.gmt
        let dateWithTime = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 14, minute: 30, second: 45))!
        let cropped = dateWithTime.cropTime()

        let hour = calendar.component(.hour, from: cropped)
        let minute = calendar.component(.minute, from: cropped)
        let second = calendar.component(.second, from: cropped)

        XCTAssertEqual(hour, 0, "Hour should be 0 after cropTime")
        XCTAssertEqual(minute, 0, "Minute should be 0 after cropTime")
        XCTAssertEqual(second, 0, "Second should be 0 after cropTime")
    }

    func testCropSeconds() {
        let calendar = Calendar.gmt
        let dateWithSeconds = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 14, minute: 30, second: 45))!
        let cropped = dateWithSeconds.cropSeconds()

        let second = calendar.component(.second, from: cropped)
        let minute = calendar.component(.minute, from: cropped)
        let hour = calendar.component(.hour, from: cropped)

        XCTAssertEqual(second, 0, "Seconds should be 0 after cropSeconds")
        XCTAssertEqual(minute, 30, "Minute should be preserved")
        XCTAssertEqual(hour, 14, "Hour should be preserved")
    }

    func testPlusOneDay() {
        let calendar = Calendar.gmt
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let nextDay = date.plusOneDay()

        let day = calendar.component(.day, from: nextDay)
        XCTAssertEqual(day, 16, "Day should be incremented by 1")
    }

    func testPlusOneDayMonthBoundary() {
        let calendar = Calendar.gmt
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 31))!
        let nextDay = date.plusOneDay()

        let month = calendar.component(.month, from: nextDay)
        let day = calendar.component(.day, from: nextDay)

        XCTAssertEqual(month, 2, "Month should roll over to February")
        XCTAssertEqual(day, 1, "Day should be 1")
    }
}
