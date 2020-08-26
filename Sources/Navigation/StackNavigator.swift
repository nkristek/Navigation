import UIKit

public final class StackNavigator<Route>:
    NSObject,
    UINavigationControllerDelegate
{
    
    // MARK: - Properties
    
    public var onChange: ((StackNavigator<Route>) -> ())?
    
    private let navigationController: UINavigationController
    
    private var viewStack: Stack<(route: Route, viewController: UIViewController)> = [] {
        didSet { onChange?(self) }
    }
    
    // MARK: - Init
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        navigationController.delegate = self
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool) {
        guard viewStack.contains(where: { $0.viewController === viewController }) else { return }
        // check if the shown viewcontroller is not the top element (due to a pop)
        guard viewStack.peek()?.viewController !== viewController else { return }
        viewStack.pop(to: { $0.viewController === viewController })
    }
}

extension StackNavigator {
    public func peek() -> Route? {
        viewStack.peek()?.route
    }
    
    @discardableResult
    public func push(route: Route,
                     viewController: UIViewController,
                     animated: Bool) -> StackNavigator<Route> {
        viewStack.push((route: route, viewController: viewController))
        navigationController.pushViewController(viewController, animated: animated)
        return self
    }
    
    public func set(_ views: [(route: Route, viewController: UIViewController)], animated: Bool) {
        viewStack = Stack(views)
        navigationController.setViewControllers(views.map(\.viewController), animated: animated)
    }
    
    @discardableResult
    public func pop(animated: Bool) -> Route? {
        guard !viewStack.isEmpty else { return nil }
        let poppedView = viewStack.pop()
        if let viewController = poppedView?.viewController {
            if navigationController.viewControllers.count > 1 {
                let poppedViewController = navigationController.popViewController(animated: animated)
                assert(viewController === poppedViewController, "The navigation stack is not in sync with the navigationController")
            } else if navigationController.viewControllers.count == 1 {
                let poppedViewController = navigationController.viewControllers[0]
                assert(viewController === poppedViewController, "The navigation stack is not in sync with the navigationController")
                navigationController.setViewControllers([], animated: animated)
            } else {
                assertionFailure("The navigation stack is not in sync with the navigationController")
            }
        }
        return poppedView?.route
    }
    
    @discardableResult
    public func pop(to route: (Route) -> Bool, animated: Bool) -> Bool {
        guard viewStack.contains(where: { route($0.route) }) else {
            // no matching route on stack
            return false
        }
        guard let topView = viewStack.peek() else { return false }
        if !route(topView.route) {
            viewStack.pop(to: { route($0.route) })
        }
        guard let previousTopView = viewStack.peek() else { return true }
        navigationController.popToViewController(previousTopView.viewController, animated: animated)
        return true
    }
}
