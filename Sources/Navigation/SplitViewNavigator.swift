import UIKit

public final class SplitViewNavigator<Route>:
    NSObject,
    UISplitViewControllerDelegate,
    UINavigationControllerDelegate
{
    
    // MARK: - Properties
    
    public var onChange: ((SplitViewNavigator<Route>) -> ())?
    
    private let splitViewController: UISplitViewController
    
    private let masterNavigationController: UINavigationController
    
    private var masterViewStack: Stack<(route: Route, viewController: UIViewController)> = [] {
        didSet { onChange?(self) }
    }
    
    private let detailNavigationController: UINavigationController
    
    private var detailViewStack: Stack<(route: Route, viewController: UIViewController)> = [] {
        didSet { onChange?(self) }
    }
    
    private let dummyViewController: UIViewController
    
    // MARK: - Init
    
    public init(splitView splitViewController: UISplitViewController,
                master masterNavigationController: UINavigationController,
                detail detailNavigationController: UINavigationController,
                dummy dummyViewController: UIViewController) {
        self.splitViewController = splitViewController
        self.masterNavigationController = masterNavigationController
        self.detailNavigationController = detailNavigationController
        self.dummyViewController = dummyViewController
        super.init()
        dummyViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        dummyViewController.navigationItem.leftItemsSupplementBackButton = true
        detailNavigationController.setViewControllers([dummyViewController], animated: false)
        splitViewController.viewControllers = [
            masterNavigationController,
            detailNavigationController
        ]
        splitViewController.delegate = self
        masterNavigationController.delegate = self
        detailNavigationController.delegate = self
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool) {
        if navigationController.transitionCoordinator?.viewController(forKey: .from) === detailNavigationController {
            setDetail([], animated: false)
        }
        
        if navigationController === masterNavigationController {
            guard masterViewStack.contains(where: { $0.viewController === viewController }) else { return }
            // check if the shown viewcontroller is not the top element (due to a pop)
            guard masterViewStack.peek()?.viewController !== viewController else { return }
            masterViewStack.pop(to: { $0.viewController === viewController })
        } else if navigationController === detailNavigationController {
            guard detailViewStack.contains(where: { $0.viewController === viewController }) else { return }
            // check if the shown viewcontroller is not the top element (due to a pop)
            guard detailViewStack.peek()?.viewController !== viewController else { return }
            detailViewStack.pop(to: { $0.viewController === viewController })
        }
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    public func splitViewController(_ splitViewController: UISplitViewController,
                                    collapseSecondary secondaryViewController:UIViewController,
                                    onto primaryViewController:UIViewController) -> Bool {
        return detailViewStack.peek() == nil
    }
}

extension SplitViewNavigator {
    public func peek() -> (master: Route?, detail: Route?) {
        return (master: masterViewStack.peek()?.route, detail: detailViewStack.peek()?.route)
    }
    
    @discardableResult
    public func pushMaster(route: Route,
                           viewController: UIViewController,
                           animated: Bool) -> SplitViewNavigator<Route> {
        masterViewStack.push((route: route, viewController: viewController))
        masterNavigationController.pushViewController(viewController, animated: animated)
        return self
    }
    
    @discardableResult
    public func pushDetail(route: Route,
                           viewController: UIViewController,
                           animated: Bool) -> SplitViewNavigator<Route> {
        let showsDummy = detailViewStack.peek() == nil && detailNavigationController.viewControllers.count > 0
        if showsDummy {
            detailViewStack = [(route: route, viewController: viewController)]
            detailNavigationController.setViewControllers([viewController], animated: animated)
        } else {
            detailViewStack.push((route: route, viewController: viewController))
            detailNavigationController.pushViewController(viewController, animated: animated)
        }
        return self
    }
    
    public func setMaster(_ views: [(route: Route, viewController: UIViewController)], animated: Bool) {
        masterViewStack = Stack(views)
        masterNavigationController.setViewControllers(views.map(\.viewController), animated: animated)
    }
    
    public func setDetail(_ views: [(route: Route, viewController: UIViewController)], animated: Bool) {
        detailViewStack = Stack(views)
        let viewControllers = views.map(\.viewController)
        viewControllers.forEach {
            $0.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            $0.navigationItem.leftItemsSupplementBackButton = true
        }
        if viewControllers.count > 0 {
            detailNavigationController.setViewControllers(viewControllers, animated: animated)
        } else {
            detailNavigationController.setViewControllers([dummyViewController], animated: animated)
        }
    }
    
    @discardableResult
    public func popMaster(animated: Bool) -> Route? {
        guard !masterViewStack.isEmpty else { return nil }
        let poppedView = masterViewStack.pop()
        if let viewController = poppedView?.viewController {
            if masterNavigationController.viewControllers.count > 1 {
                let poppedViewController = masterNavigationController.popViewController(animated: animated)
                assert(viewController === poppedViewController, "The navigation stack is not in sync with the navigationController")
            } else if masterNavigationController.viewControllers.count == 1 {
                let poppedViewController = masterNavigationController.viewControllers[0]
                assert(viewController === poppedViewController, "The navigation stack is not in sync with the navigationController")
                masterNavigationController.setViewControllers([], animated: animated)
            } else {
                assertionFailure("The navigation stack is not in sync with the navigationController")
            }
        }
        return poppedView?.route
    }
    
    @discardableResult
    public func popDetail(animated: Bool) -> Route? {
        guard !detailViewStack.isEmpty else { return nil }
        let poppedView = detailViewStack.pop()
        if let viewController = poppedView?.viewController {
            if detailNavigationController.viewControllers.count > 1 {
                let poppedViewController = detailNavigationController.popViewController(animated: animated)
                assert(viewController === poppedViewController, "The navigation stack is not in sync with the navigationController")
            } else if detailNavigationController.viewControllers.count == 1 {
                let poppedViewController = detailNavigationController.viewControllers[0]
                assert(viewController === poppedViewController, "The navigation stack is not in sync with the navigationController")
                detailNavigationController.setViewControllers([dummyViewController], animated: animated)
            } else {
                assertionFailure("The navigation stack is not in sync with the navigationController")
            }
        }
        return poppedView?.route
    }
    
    @discardableResult
    public func popMaster(to route: (Route) -> Bool, animated: Bool) -> Bool {
        guard masterViewStack.contains(where: { route($0.route) }) else {
            // no matching route on stack
            return false
        }
        guard let topView = masterViewStack.peek() else { return false }
        if !route(topView.route) {
            masterViewStack.pop(to: { route($0.route) })
        }
        guard let previousTopView = masterViewStack.peek() else { return true }
        masterNavigationController.popToViewController(previousTopView.viewController, animated: animated)
        return true
    }
    
    @discardableResult
    public func popDetail(to route: (Route) -> Bool, animated: Bool) -> Bool {
        guard detailViewStack.contains(where: { route($0.route) }) else {
            // no matching route on stack
            return false
        }
        guard let topView = detailViewStack.peek() else { return false }
        if !route(topView.route) {
            detailViewStack.pop(to: { route($0.route) })
        }
        guard let previousTopView = detailViewStack.peek() else { return true }
        detailNavigationController.popToViewController(previousTopView.viewController, animated: animated)
        return true
    }
}
