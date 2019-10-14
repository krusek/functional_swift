import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(com_korbonix_functionalTests.allTests),
    ]
}
#endif
