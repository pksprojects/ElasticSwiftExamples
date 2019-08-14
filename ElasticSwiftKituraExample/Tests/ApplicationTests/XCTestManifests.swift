import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ElasticSwiftKituraTests.allTests),
    ]
}
#endif
