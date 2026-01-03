import XCTest
@testable import WorkTimeUtil

final class WorkEventTests: XCTestCase {

    // MARK: - isWork Tests

    func testIsWorkForOffice() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .office, commentary: nil)
        XCTAssertTrue(event.isWork, "Office should be counted as work")
    }

    func testIsWorkForHomeOffice() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .homeOffice, commentary: nil)
        XCTAssertTrue(event.isWork, "Home Office should be counted as work")
    }

    func testIsWorkForMeeting() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .meeting, commentary: nil)
        XCTAssertTrue(event.isWork, "Meeting should be counted as work")
    }

    func testIsNotWorkForVacation() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .vacation, commentary: nil)
        XCTAssertFalse(event.isWork, "Vacation should not be counted as work")
    }

    func testIsNotWorkForSick() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .sick, commentary: nil)
        XCTAssertFalse(event.isWork, "Sick should not be counted as work")
    }

    func testIsNotWorkForHoliday() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .holiday, commentary: nil)
        XCTAssertFalse(event.isWork, "Holiday should not be counted as work")
    }

    func testIsNotWorkForCompanyEvent() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .companyEvent, commentary: nil)
        XCTAssertFalse(event.isWork, "Company Event should not be counted as work")
    }

    func testIsNotWorkForCompensatory() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .compensatory, commentary: nil)
        XCTAssertFalse(event.isWork, "Compensatory should not be counted as work")
    }

    // MARK: - reducesTarget Tests

    func testReducesTargetForVacation() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .vacation, commentary: nil)
        XCTAssertTrue(event.reducesTarget, "Vacation should reduce target hours")
    }

    func testReducesTargetForSick() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .sick, commentary: nil)
        XCTAssertTrue(event.reducesTarget, "Sick should reduce target hours")
    }

    func testReducesTargetForHoliday() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .holiday, commentary: nil)
        XCTAssertTrue(event.reducesTarget, "Holiday should reduce target hours")
    }

    func testReducesTargetForCompanyEvent() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .companyEvent, commentary: nil)
        XCTAssertTrue(event.reducesTarget, "Company Event should reduce target hours")
    }

    func testReducesTargetForCompensatory() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .compensatory, commentary: nil)
        XCTAssertTrue(event.reducesTarget, "Compensatory should reduce target hours")
    }

    func testDoesNotReduceTargetForOffice() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .office, commentary: nil)
        XCTAssertFalse(event.reducesTarget, "Office should not reduce target hours")
    }

    func testDoesNotReduceTargetForHomeOffice() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .homeOffice, commentary: nil)
        XCTAssertFalse(event.reducesTarget, "Home Office should not reduce target hours")
    }

    func testDoesNotReduceTargetForMeeting() {
        let event = WorkEvent(startDate: Date(), endDate: Date(), type: .meeting, commentary: nil)
        XCTAssertFalse(event.reducesTarget, "Meeting should not reduce target hours")
    }
}
