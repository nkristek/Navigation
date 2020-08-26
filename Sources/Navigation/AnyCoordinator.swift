import UIKit

// MARK: - Coordinator+EraseToAnyCoordinator

extension Coordinator {
    @inlinable
    public func eraseToAnyCoordinator() -> AnyCoordinator<Route> {
        return .init(coordinator: self)
    }
}

// MARK: - AnyCoordinator

public final class AnyCoordinator<Route>: Coordinator {
    
    // MARK: - Properties
    
    @usableFromInline
    internal let _rootViewController: () -> UIViewController
    
    @usableFromInline
    internal let _handle: (Route) -> ()
    
    // MARK: - Init
    
    public init<CoordinatorType: Coordinator>(coordinator: CoordinatorType) where CoordinatorType.Route == Route {
        _rootViewController = { coordinator.rootViewController }
        _handle = coordinator.handle(route:)
    }
    
    // MARK: - Coordinator
    
    @inlinable
    public var rootViewController: UIViewController { _rootViewController() }
    
    @inlinable
    public func handle(route: Route) { _handle(route) }
}
