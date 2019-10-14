import XCTest
@testable import com_korbonix_functional

final class com_korbonix_functionalTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(com_korbonix_functional().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
