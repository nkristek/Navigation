import UIKit

public final class TabBarNavigator<Route>:
    NSObject,
    UITabBarControllerDelegate
{
    
    // MARK: - Properties
    
    public var onChange: ((TabBarNavigator<Route>) -> ())?
    
    private let tabBarController: UITabBarController
    
    private let views: [(route: Route, viewController: UIViewController)]
    
    public private(set) var selectedRoute: Route? {
        didSet { onChange?(self) }
    }
    
    // MARK: - Init
    
    public init(tabBarController: UITabBarController,
                views: [(route: Route, viewController: UIViewController)]) {
        self.tabBarController = tabBarController
        self.views = views
        self.selectedRoute = views.first?.route
        super.init()
        tabBarController.setViewControllers(views.map(\.viewController), animated: false)
        tabBarController.delegate = self
    }
    
    // MARK: - UITabBarControllerDelegate
    
    public func tabBarController(_ tabBarController: UITabBarController,
                                 didSelect viewController: UIViewController) {
        selectedRoute = views.first(where: { $0.viewController === viewController })?.route
    }
}

extension TabBarNavigator {
    @discardableResult
    public func select(route: (Route) -> Bool) -> Bool {
        guard let index = views.firstIndex(where: { route($0.route) }) else { return false }
        tabBarController.selectedIndex = index
        selectedRoute = views[index].route
        return true
    }
}
