@testable import Navigation
import XCTest

final class SplitViewNavigatorTests: XCTestCase {
    private struct SplitViewNavigatorElement: Equatable, CustomStringConvertible {
        let master: Int?
        let detail: Int?
        var description: String { "(master: \(master != nil ? "\(master!)" : "nil"), detail: \(detail != nil ? "\(detail!)" : "nil"))" }
    }

    func testPeek() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        
        var (master, detail) = navigator.peek()
        XCTAssertEqual(master, nil)
        XCTAssertEqual(detail, nil)
        
        navigator.pushMaster(route: 1, viewController: UIViewController(), animated: false)
        (master, detail) = navigator.peek()
        XCTAssertEqual(master, 1)
        XCTAssertEqual(detail, nil)
    }

    func testPushMaster() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        
        navigator.pushMaster(route: 1, viewController: firstViewController, animated: false)
        XCTAssertEqual([
            .init(master: 1, detail: nil)
        ], changes)
        XCTAssertEqual([firstViewController], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
        
        navigator.pushMaster(route: 2, viewController: secondViewController, animated: false)
        XCTAssertEqual([
            .init(master: 1, detail: nil),
            .init(master: 2, detail: nil)
        ], changes)
        XCTAssertEqual([firstViewController, secondViewController], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
    }
    
    func testPushDetail() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        
        navigator.pushDetail(route: 1, viewController: firstViewController, animated: false)
        XCTAssertEqual([
            .init(master: nil, detail: 1)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([firstViewController], detailNavigationController.viewControllers)
        
        navigator.pushDetail(route: 2, viewController: secondViewController, animated: false)
        XCTAssertEqual([
            .init(master: nil, detail: 1),
            .init(master: nil, detail: 2)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([firstViewController, secondViewController], detailNavigationController.viewControllers)
    }

    func testSetMaster() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        
        navigator.setMaster([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ], animated: false)
        XCTAssertEqual([
            .init(master: 2, detail: nil)
        ], changes)
        XCTAssertEqual([firstViewController, secondViewController], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
    }
    
    func testSetDetail() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        
        navigator.setDetail([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ], animated: false)
        XCTAssertEqual([
            .init(master: nil, detail: 2)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([firstViewController, secondViewController], detailNavigationController.viewControllers)
    }
    
    func testPopMasterViaNavigator() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        
        XCTAssertNil(navigator.popMaster(animated: false))
        XCTAssertEqual([], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
        
        navigator.pushMaster(route: 1, viewController: firstViewController, animated: false)
        XCTAssertEqual(navigator.popMaster(animated: false), 1)
        XCTAssertEqual([
            .init(master: 1, detail: nil),
            .init(master: nil, detail: nil)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
        changes = []
        
        navigator.setMaster([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ], animated: false)
        XCTAssertEqual(navigator.popMaster(animated: false), 2)
        XCTAssertEqual([
            .init(master: 2, detail: nil),
            .init(master: 1, detail: nil)
        ], changes)
        XCTAssertEqual([firstViewController], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
    }
    
    func testPopDetailViaNavigator() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        
        XCTAssertNil(navigator.popDetail(animated: false))
        XCTAssertEqual([], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
        
        navigator.pushDetail(route: 1, viewController: firstViewController, animated: false)
        XCTAssertEqual(navigator.popDetail(animated: false), 1)
        XCTAssertEqual([
            .init(master: nil, detail: 1),
            .init(master: nil, detail: nil)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
        changes = []
        
        navigator.setDetail([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ], animated: false)
        XCTAssertEqual(navigator.popDetail(animated: false), 2)
        XCTAssertEqual([
            .init(master: nil, detail: 2),
            .init(master: nil, detail: 1)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([firstViewController], detailNavigationController.viewControllers)
    }
    
    func testPopMasterViaNavigationController() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        
        navigator.setMaster([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ], animated: false)
        masterNavigationController.popViewController(animated: false)
        navigator.navigationController(masterNavigationController, didShow: firstViewController, animated: false)
        XCTAssertEqual([
            .init(master: 2, detail: nil),
            .init(master: 1, detail: nil)
        ], changes)
        XCTAssertEqual([firstViewController], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
    }
    
    func testPopDetailViaNavigationController() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        
        navigator.setDetail([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController)
        ], animated: false)
        detailNavigationController.popViewController(animated: false)
        navigator.navigationController(detailNavigationController, didShow: firstViewController, animated: false)
        XCTAssertEqual([
            .init(master: nil, detail: 2),
            .init(master: nil, detail: 1)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([firstViewController], detailNavigationController.viewControllers)
    }
    
    func testPopMasterToRoute() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let thirdViewController = UIViewController()
        navigator.setMaster([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController),
            (route: 3, viewController: thirdViewController)
        ], animated: false)
        navigator.popMaster(to: { $0 == 1 }, animated: false)
        XCTAssertEqual([
            .init(master: 3, detail: nil),
            .init(master: 1, detail: nil)
        ], changes)
        XCTAssertEqual([firstViewController], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
    }
    
    func testPopDetailToRoute() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let thirdViewController = UIViewController()
        navigator.setDetail([
            (route: 1, viewController: firstViewController),
            (route: 2, viewController: secondViewController),
            (route: 3, viewController: thirdViewController)
        ], animated: false)
        navigator.popDetail(to: { $0 == 1 }, animated: false)
        XCTAssertEqual([
            .init(master: nil, detail: 3),
            .init(master: nil, detail: 1)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([firstViewController], detailNavigationController.viewControllers)
    }
    
    func testClearMaster() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        navigator.setMaster([
            (route: 1, viewController: UIViewController())
        ], animated: false)
        navigator.setMaster([], animated: false)
        XCTAssertEqual([
            .init(master: 1, detail: nil),
            .init(master: nil, detail: nil)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
    }
    
    func testClearDetail() {
        let splitViewController = UISplitViewController()
        let masterNavigationController = UINavigationController()
        let detailNavigationController = UINavigationController()
        let dummyViewController = UIViewController()
        let navigator = SplitViewNavigator<Int>(splitView: splitViewController,
                                                master: masterNavigationController,
                                                detail: detailNavigationController,
                                                dummy: dummyViewController)
        var changes: [SplitViewNavigatorElement] = []
        navigator.onChange = { navigator in
            let (master, detail) = navigator.peek()
            changes.append(.init(master: master, detail: detail))
        }
        
        navigator.setDetail([
            (route: 1, viewController: UIViewController())
        ], animated: false)
        navigator.setDetail([], animated: false)
        XCTAssertEqual([
            .init(master: nil, detail: 1),
            .init(master: nil, detail: nil)
        ], changes)
        XCTAssertEqual([], masterNavigationController.viewControllers)
        XCTAssertEqual([dummyViewController], detailNavigationController.viewControllers)
    }
    
    static let allTests = [
        ("testPeek", testPeek),
        ("testPushMaster", testPushMaster),
        ("testPushDetail", testPushDetail),
        ("testSetMaster", testSetMaster),
        ("testSetDetail", testSetDetail),
        ("testPopMasterViaNavigator", testPopMasterViaNavigator),
        ("testPopDetailViaNavigator", testPopDetailViaNavigator),
        ("testPopMasterViaNavigationController", testPopMasterViaNavigationController),
        ("testPopDetailViaNavigationController", testPopDetailViaNavigationController),
        ("testPopMasterToRoute", testPopMasterToRoute),
        ("testPopDetailToRoute", testPopDetailToRoute),
        ("testClearMaster", testClearMaster),
        ("testClearDetail", testClearDetail)
    ]
}
