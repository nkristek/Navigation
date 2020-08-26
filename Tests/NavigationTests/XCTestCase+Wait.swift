import XCTest

extension XCTestCase {
    internal func wait(for duration: TimeInterval) {
        let waitExpectation = expectation(description: "Wait for \(duration)")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration,
                                      execute: waitExpectation.fulfill)
        wait(for: [waitExpectation], timeout: duration + 0.5)
    }
}
