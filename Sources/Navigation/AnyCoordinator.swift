import UIKit

// MARK: - Coordinator+EraseToAnyCoordinator

extension Coordinator {
    @inlinable
    public func eraseToAnyCoordinator() -> AnyCoordinator<Route> {
        return .init(coordinator: self)
    }
	
	@inlinable
	public func eraseToAnyCoordinator<TargetRoute>(transform: @escaping (TargetRoute) -> Route) -> AnyCoordinator<TargetRoute> {
		return .init(coordinator: self, transform: transform)
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
	
	public init<CoordinatorType: Coordinator>(coordinator: CoordinatorType,
											  transform: @escaping (Route) -> CoordinatorType.Route) {
		_rootViewController = { coordinator.rootViewController }
		_handle = { coordinator.handle(route: transform($0)) }
	}
    
    // MARK: - Coordinator
    
    @inlinable
    public var rootViewController: UIViewController { _rootViewController() }
    
    @inlinable
    public func handle(route: Route) { _handle(route) }
}
