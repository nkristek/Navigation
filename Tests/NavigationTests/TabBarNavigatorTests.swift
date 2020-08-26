@testable import Navigation
import XCTest

final class TabBarNavigatorTests: XCTestCase {
    private struct TabBarNavigatorElement: Equatable, CustomStringConvertible {
        let selected: Int?
        var description: String { "(selected: \(selected != nil ? "\(selected!)" : "nil"))" }
    }
    
    func testSelect() {
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let tabBarController = UITabBarController()
        let navigator = TabBarNavigator<Int>(tabBarController: tabBarController, views: [
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ])
        var changes: [TabBarNavigatorElement] = []
        navigator.onChange = { _ in
            changes.append(.init(selected: navigator.selectedRoute))
        }
        
        XCTAssertEqual(1, navigator.selectedRoute)
        XCTAssert(navigator.select(route: { $0 == 2 }))
        XCTAssertEqual(2, navigator.selectedRoute)
        XCTAssertEqual([
            .init(selected: 2)
        ], changes)
    }
    
    func testSelectNonExistent() {
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let tabBarController = UITabBarController()
        let navigator = TabBarNavigator<Int>(tabBarController: tabBarController, views: [
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ])
        var changes: [TabBarNavigatorElement] = []
        navigator.onChange = { _ in
            changes.append(.init(selected: navigator.selectedRoute))
        }
        
        XCTAssertEqual(1, navigator.selectedRoute)
        XCTAssertFalse(navigator.select(route: { _ in false }))
        XCTAssertEqual(1, navigator.selectedRoute)
        XCTAssertEqual([], changes)
    }
    
    func testEmpty() {
        let tabBarController = UITabBarController()
        let navigator = TabBarNavigator<Int>(tabBarController: tabBarController, views: [])
        var changes: [TabBarNavigatorElement] = []
        navigator.onChange = { _ in
            changes.append(.init(selected: navigator.selectedRoute))
        }
        
        XCTAssertEqual(nil, navigator.selectedRoute)
        XCTAssertFalse(navigator.select(route: { _ in true }))
        XCTAssertEqual(nil, navigator.selectedRoute)
        XCTAssertEqual([], changes)
    }
    
    static let allTests = [
        ("testSelect", testSelect),
        ("testSelectNonExistent", testSelectNonExistent),
        ("testEmpty", testEmpty)
    ]
}
