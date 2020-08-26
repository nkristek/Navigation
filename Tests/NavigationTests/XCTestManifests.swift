import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnyCoordinatorTests.allTests),
        testCase(SplitViewNavigatorTests.allTests),
        testCase(StackNavigatorTests.allTests),
        testCase(StackTests.allTests),
        testCase(TabBarNavigatorTests.allTests),
        testCase(UnownedCoordinatorTests.allTests),
    ]
}
#endif
