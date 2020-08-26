import UIKit

// MARK: - Coordinator+EraseToUnownedCoordinator

extension Coordinator {
    @inlinable
    public func eraseToUnownedCoordinator() -> UnownedCoordinator<Route> {
        return .init(coordinator: self)
    }
}

// MARK: - UnownedCoordinator

public final class UnownedCoordinator<Route>: Coordinator {
    
    // MARK: - Properties
    
    @usableFromInline
    internal let _rootViewController: () -> UIViewController
    
    @usableFromInline
    internal let _handle: (Route) -> ()
    
    // MARK: - Init
    
    public init<CoordinatorType: Coordinator>(coordinator: CoordinatorType) where CoordinatorType.Route == Route {
        _rootViewController = { [unowned coordinator] in coordinator.rootViewController }
        _handle = { [unowned coordinator] route in coordinator.handle(route: route) }
    }
    
    // MARK: - Coordinator
    
    @inlinable
    public var rootViewController: UIViewController { _rootViewController() }
    
    @inlinable
    public func handle(route: Route) { _handle(route) }
}
