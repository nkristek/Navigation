@testable import Navigation
import XCTest

final class StackNavigatorTests: XCTestCase {
    private struct StackNavigatorElement: Equatable, CustomStringConvertible {
        let peek: Int?
        var description: String { "(peek: \(peek != nil ? "\(peek!)" : "nil"))" }
    }
    
    func testPeek() {
        let navigationController = UINavigationController()
        let navigator = StackNavigator<Int>(navigationController: navigationController)
        
        XCTAssertEqual(nil, navigator.peek())
        navigator.push(route: 1, viewController: UIViewController(), animated: false)
        XCTAssertEqual(1, navigator.peek())
    }
    
    func testPush() {
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let navigationController = UINavigationController()
        let navigator = StackNavigator<Int>(navigationController: navigationController)
        var changes: [StackNavigatorElement] = []
        navigator.onChange = { _ in
            changes.append(.init(peek: navigator.peek()))
        }
        
        navigator.push(route: 1, viewController: firstViewController, animated: false)
        XCTAssertEqual([
            .init(peek: 1)
        ], changes)
        XCTAssertEqual([firstViewController], navigationController.viewControllers)
        
        navigator.push(route: 2, viewController: secondViewController, animated: false)
        XCTAssertEqual([
            .init(peek: 1),
            .init(peek: 2)
        ], changes)
        XCTAssertEqual([firstViewController, secondViewController], navigationController.viewControllers)
    }
    
    func testSet() {
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let navigationController = UINavigationController()
        let navigator = StackNavigator<Int>(navigationController: navigationController)
        var changes: [StackNavigatorElement] = []
        navigator.onChange = { _ in
            changes.append(.init(peek: navigator.peek()))
        }
        
        navigator.set([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ], animated: false)
        XCTAssertEqual([
            .init(peek: 2)
        ], changes)
        XCTAssertEqual([firstViewController, secondViewController], navigationController.viewControllers)
    }
    
    func testPopViaNavigator() {
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let navigationController = UINavigationController()
        let navigator = StackNavigator<Int>(navigationController: navigationController)
        var changes: [StackNavigatorElement] = []
        navigator.onChange = { _ in
            changes.append(.init(peek: navigator.peek()))
        }
        
        XCTAssertNil(navigator.pop(animated: false))
        XCTAssertEqual([], changes)
        XCTAssertEqual([], navigationController.viewControllers)
        
        navigator.push(route: 1, viewController: firstViewController, animated: false)
        XCTAssertEqual(navigator.pop(animated: false), 1)
        XCTAssertEqual([
            .init(peek: 1),
            .init(peek: nil)
        ], changes)
        XCTAssertEqual([], navigationController.viewControllers)
        changes = []
        
        navigator.set([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ], animated: false)
        XCTAssertEqual(navigator.pop(animated: false), 2)
        XCTAssertEqual([
            .init(peek: 2),
            .init(peek: 1)
        ], changes)
        XCTAssertEqual([firstViewController], navigationController.viewControllers)
    }
    
    func testPopViaNavigationController() {
        let navigationController = UINavigationController()
        let navigator = StackNavigator<Int>(navigationController: navigationController)
        var changes: [StackNavigatorElement] = []
        navigator.onChange = { _ in
            changes.append(.init(peek: navigator.peek()))
        }
        
        let firstViewController = UIViewController()
        navigator.set([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: UIViewController())
        ], animated: false)
        navigationController.popViewController(animated: false)
        navigator.navigationController(navigationController, didShow: firstViewController, animated: false)
        XCTAssertEqual([
            .init(peek: 2),
            .init(peek: 1)
        ], changes)
        XCTAssertEqual([firstViewController], navigationController.viewControllers)
    }
    
    func testPopToRoute() {
        let navigationController = UINavigationController()
        let navigator = StackNavigator<Int>(navigationController: navigationController)
        var changes: [StackNavigatorElement] = []
        navigator.onChange = { _ in
            changes.append(.init(peek: navigator.peek()))
        }
        
        let firstViewController = UIViewController()
        navigator.set([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: UIViewController()),
            (route: 3, viewController: UIViewController())
        ], animated: false)
        XCTAssertEqual(navigator.pop(to: { $0 == 1 }, animated: false), true)
        XCTAssertEqual([
            .init(peek: 3),
            .init(peek: 1)
        ], changes)
        XCTAssertEqual([firstViewController], navigationController.viewControllers)
    }
    
    static let allTests = [
        ("testPeek", testPeek),
        ("testPush", testPush),
        ("testSet", testSet),
        ("testPopNavigator", testPopViaNavigator),
        ("testPopNavigationController", testPopViaNavigationController),
        ("testPopToRoute", testPopToRoute)
    ]
}
