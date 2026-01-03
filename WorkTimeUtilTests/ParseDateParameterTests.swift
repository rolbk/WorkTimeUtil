import XCTest
@testable import WorkTimeUtil

final class ParseDateParameterTests: XCTestCase {

    // MARK: - Week Parameter Tests

    func testParseCurrentWeek() {
        let result = parseDateParameter("W")
        XCTAssertNotNil(result, "W should be a valid parameter")

        let (expectedStart, expectedEnd) = CalUtil.startAndEndDatesForCurrentWeek()
        XCTAssertEqual(result?.startDate, expectedStart)
        XCTAssertEqual(result?.endDate, expectedEnd)
    }

    func testParseSpecificWeek() {
        let result = parseDateParameter("W5")
        XCTAssertNotNil(result, "W5 should be a valid parameter")
    }

    func testParseWeekWithYear() {
        let result = parseDateParameter("W10/25")
        XCTAssertNotNil(result, "W10/25 should be a valid parameter")

        let calendar = Calendar.gmt
        let year = calendar.component(.yearForWeekOfYear, from: result!.startDate)
        XCTAssertEqual(year, 2025, "Year should be 2025")
    }

    func testParseWeekWithFullYear() {
        let result = parseDateParameter("W10/2024")
        XCTAssertNotNil(result, "W10/2024 should be a valid parameter")

        let calendar = Calendar.gmt
        let year = calendar.component(.yearForWeekOfYear, from: result!.startDate)
        XCTAssertEqual(year, 2024, "Year should be 2024")
    }

    // MARK: - Month Parameter Tests

    func testParseCurrentMonth() {
        let result = parseDateParameter("M")
        XCTAssertNotNil(result, "M should be a valid parameter")

        let (expectedStart, expectedEnd) = CalUtil.startAndEndDatesForCurrentMonth()
        XCTAssertEqual(result?.startDate, expectedStart)
        XCTAssertEqual(result?.endDate, expectedEnd)
    }

    func testParseSpecificMonth() {
        let result = parseDateParameter("M6")
        XCTAssertNotNil(result, "M6 should be a valid parameter")
    }

    func testParseMonthWithYear() {
        let result = parseDateParameter("M3/25")
        XCTAssertNotNil(result, "M3/25 should be a valid parameter")

        let calendar = Calendar.gmt
        let year = calendar.component(.year, from: result!.startDate)
        let month = calendar.component(.month, from: result!.startDate)
        XCTAssertEqual(year, 2025, "Year should be 2025")
        XCTAssertEqual(month, 3, "Month should be March")
    }

    func testParseMonthWithFullYear() {
        let result = parseDateParameter("M12/2024")
        XCTAssertNotNil(result, "M12/2024 should be a valid parameter")

        let calendar = Calendar.gmt
        let year = calendar.component(.year, from: result!.startDate)
        let month = calendar.component(.month, from: result!.startDate)
        XCTAssertEqual(year, 2024, "Year should be 2024")
        XCTAssertEqual(month, 12, "Month should be December")
    }

    // MARK: - Invalid Parameter Tests

    func testParseInvalidParameter() {
        let result = parseDateParameter("invalid")
        XCTAssertNil(result, "Invalid parameter should return nil")
    }

    func testParseEmptyParameter() {
        let result = parseDateParameter("")
        XCTAssertNil(result, "Empty parameter should return nil")
    }

    func testParseNumericOnlyParameter() {
        let result = parseDateParameter("5")
        XCTAssertNil(result, "Numeric-only parameter should return nil")
    }
}
