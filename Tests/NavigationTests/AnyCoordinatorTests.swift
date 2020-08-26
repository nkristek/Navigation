@testable import Navigation
import UIKit
import XCTest

final class AnyCoordinatorTests: XCTestCase {
    
    private class TestCoordinator: Coordinator {
        let rootViewController: UIViewController
        
        private(set) var currentRoute: Int?
        
        func handle(route: Int) {
            currentRoute = route
        }
        
        init(rootViewController: UIViewController) {
            self.rootViewController = rootViewController
        }
    }
    
    func testRootViewController() {
        let viewController = UIViewController()
        let coordinator = TestCoordinator(rootViewController: viewController)
        let anyCoordinator = coordinator.eraseToAnyCoordinator()
        XCTAssert(viewController === anyCoordinator.rootViewController)
    }
    
    func testHandle() {
        let viewController = UIViewController()
        let coordinator = TestCoordinator(rootViewController: viewController)
        let anyCoordinator = coordinator.eraseToAnyCoordinator()
        XCTAssertEqual(nil, coordinator.currentRoute)
        anyCoordinator.handle(route: 3)
        XCTAssertEqual(3, coordinator.currentRoute)
    }
    
    func testAnyCoordinatorRetainsWrappedCoordinator() {
        let viewController = UIViewController()
        let coordinator = createAnyCoordinator(rootViewController: viewController)
        XCTAssert(viewController === coordinator.rootViewController)
    }
    
    private func createAnyCoordinator(rootViewController: UIViewController) -> AnyCoordinator<Int> {
        return TestCoordinator(rootViewController: rootViewController)
            .eraseToAnyCoordinator()
    }
    
    static let allTests = [
        ("testRootViewController", testRootViewController),
        ("testHandle", testHandle),
        ("testAnyCoordinatorRetainsWrappedCoordinator", testAnyCoordinatorRetainsWrappedCoordinator),
    ]
}
