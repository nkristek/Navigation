@testable import Navigation
import XCTest

final class UnownedCoordinatorTests: XCTestCase {
    private class TestCoordinator: Coordinator {
        let rootViewController: UIViewController
        
        private(set) var currentRoute: Int?
        
        func handle(route: Int) {
            currentRoute = route
        }
        
        private let onDeinit: () -> ()
        
        init(rootViewController: UIViewController, onDeinit: @escaping () -> () = { }) {
            self.rootViewController = rootViewController
            self.onDeinit = onDeinit
        }
        
        deinit {
            onDeinit()
        }
    }
    
    func testRootViewController() {
        let viewController = UIViewController()
        let coordinator = TestCoordinator(rootViewController: viewController)
        let unownedCoordinator = coordinator.eraseToUnownedCoordinator()
        XCTAssert(viewController === unownedCoordinator.rootViewController)
    }
    
    func testHandle() {
        let viewController = UIViewController()
        let coordinator = TestCoordinator(rootViewController: viewController)
        let unownedCoordinator = coordinator.eraseToUnownedCoordinator()
        XCTAssertEqual(nil, coordinator.currentRoute)
        unownedCoordinator.handle(route: 3)
        XCTAssertEqual(3, coordinator.currentRoute)
    }
    
    func testUnownedCoordinatorDoesNotRetainWrappedCoordinator() {
        let viewController = UIViewController()
        var isRetained = true
        let coordinator = createUnownedCoordinator(rootViewController: viewController, onDeinit: { isRetained = false })
        XCTAssertFalse(isRetained)
        XCTAssertNotNil(coordinator)
    }
    
    private func createUnownedCoordinator(rootViewController: UIViewController,
                                          onDeinit: @escaping () -> ()) -> UnownedCoordinator<Int> {
        let coordinator = TestCoordinator(rootViewController: rootViewController, onDeinit: onDeinit)
        return coordinator.eraseToUnownedCoordinator()
    }
    
    static let allTests = [
        ("testRootViewController", testRootViewController),
        ("testHandle", testHandle),
        ("testUnownedCoordinatorDoesNotRetainWrappedCoordinator", testUnownedCoordinatorDoesNotRetainWrappedCoordinator),
    ]
}
