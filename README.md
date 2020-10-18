# Navigation

This library helps you to implement the MVVM-Coordinator pattern by including everything you need to do it!

## Example
### Pure Swift + dependency injection

<details>
  <summary>AppDelegate</summary>
	
```swift
let window = UIWindow(windowScene: windowScene)
self.window = window

let coordinator = AppCoordinator()
self.coordinator = coordinator

let itemListCoordinator = ItemListCoordinator(appCoordinator: coordinator)
self.itemListCoordinator = itemListCoordinator // needed because of unowned reference
let configurationCoordinator = ConfigurationCoordinator(appCoordinator: coordinator)
self.configurationCoordinator = configurationCoordinator // needed because of unowned reference
let viewModel = ItemListViewModel(coordinator: itemListCoordinator.eraseToUnownedCoordinator(),
                                  configurationCoordinator: configurationCoordinator.eraseToUnownedCoordinator())
coordinator.handle(route: .start(viewModel))

window.rootViewController = coordinator.rootViewController
window.makeKeyAndVisible()
```

</details>

<details>
  <summary>ViewModel</summary>
	
```swift
enum ItemListRoute {
	case item(String)
	case configuration(ConfigurationViewModelType)
	case help
}

typealias ItemListViewModelType = ItemListViewModelInputs & ItemListViewModelOutputs

protocol ItemListViewModelInputs {
	func itemPressed(_ item: String)
	func connectionPressed()
	func helpPressed()
}

protocol ItemListViewModelOutputs {
	var items: [String] { get }
}

final class ItemListViewModel: ItemListViewModelType {
	// MARK: - Private state
	
	private let coordinator: UnownedCoordinator<ItemListRoute>
	private let configurationCoordinator: UnownedCoordinator<ConfigurationRoute>
		
	// MARK: - Inputs
	
	func itemPressed(_ item: String) {
		coordinator.handle(route: .item(item))
	}
	
	func connectionPressed() {
		let viewModel = ConfigurationViewModel(coordinator: configurationCoordinator)
		coordinator.handle(route: .configuration(viewModel))
	}
	
	func helpPressed() {
		coordinator.handle(route: .help)
	}
	
	// MARK: - Outputs
	
	let (navigationSignal, navigationObserver) = Signal<ItemListRoute, Never>.pipe()
	let items = ["First", "Second", "Third"]
	
	// MARK: - Init
	
	init(coordinator: UnownedCoordinator<ItemListRoute>, configurationCoordinator: UnownedCoordinator<ConfigurationRoute>) {
		self.coordinator = coordinator
		self.configurationCoordinator = configurationCoordinator
	}
}
```

</details>

<details>
  <summary>Coordinator</summary>
	
```swift
enum AppRoute {
	case start(ItemListViewModelType)
	case itemList(ItemListRoute)
	case configuration(ConfigurationRoute)
}

final class AppCoordinator: Coordinator {
	// MARK: - Properties
	
	private let navigator: StackNavigator<AppRoute>
	
	private let navigationController = UINavigationController()
	
	// MARK: - Init
	
	init() {
		navigator = StackNavigator(navigationController: navigationController)
	}
	
	// MARK: - Coordinator
	
	var rootViewController: UIViewController { navigationController }
	
	func handle(route: AppRoute) {
		switch route {
		case let .start(viewModel):
			let viewController = ItemListViewController(viewModel: viewModel)
			navigator.set([(route: route, viewController: viewController)], animated: false)
			
		case let .itemList(itemListRoute):
			handle(route: route, listRoute: itemListRoute)
			
		case let .configuration(configurationRoute):
			handle(route: route, configurationRoute: configurationRoute)
		}
	}
	
	private func handle(route: AppRoute, listRoute: ItemListRoute) {
		switch listRoute {
		case let .item(item):
			let viewController = ItemViewController(item: item)
			navigator.push(route: route, viewController: viewController, animated: true)
			
		case let .configuration(viewModel):
			let viewController = ConfigurationViewController(viewModel: viewModel)
			navigator.push(route: route, viewController: viewController, animated: true)
			
		case .help:
			let viewController = HelpViewController()
			navigator.push(route: route, viewController: viewController, animated: true)
		}
	}
	
	private func handle(route: AppRoute, configurationRoute: ConfigurationRoute) {
		// ...
	}
}

final class ItemListCoordinator: Coordinator {
	// MARK: - Properties
	
	private let appCoordinator: AppCoordinator
	
	// MARK: - Init
	
	init(appCoordinator: AppCoordinator) {
		self.appCoordinator = appCoordinator
	}
	
	// MARK: - Coordinator
	
	var rootViewController: UIViewController { appCoordinator.rootViewController }
	
	func handle(route: ItemListRoute) {
		appCoordinator.handle(route: .itemList(route))
	}
}

final class ConfigurationCoordinator: Coordinator {
	// MARK: - Properties
	
	private let appCoordinator: AppCoordinator
	
	// MARK: - Init
	
	init(appCoordinator: AppCoordinator) {
		self.appCoordinator = appCoordinator
	}
	
	// MARK: - Coordinator
	
	var rootViewController: UIViewController { appCoordinator.rootViewController }
	
	func handle(route: ConfigurationRoute) {
		appCoordinator.handle(route: .configuration(route))
	}
}
```

</details>

### ReactiveSwift + Signals

<details>
  <summary>ViewModel</summary>
	
```swift
enum ItemListRoute {
	case item(String)
	case configuration(ConfigurationViewModelType)
	case help
}

typealias ItemListViewModelType = ItemListViewModelInputs & ItemListViewModelOutputs

protocol ItemListViewModelInputs {
	var itemPressedObserver: Signal<String, Never>.Observer { get }
	var connectionPressedObserver: Signal<Void, Never>.Observer { get }
	var helpPressedObserver: Signal<Void, Never>.Observer { get }
}

protocol ItemListViewModelOutputs {
	var navigationSignal: Signal<ItemListRoute, Never> { get }
	var items: Property<[String]> { get }
}

final class ItemListViewModel: ItemListViewModelType {
	// MARK: - Private state
	
	private let (lifetime, token) = Lifetime.make()
	
	// MARK: - Inputs
	
	let (itemPressedSignal, itemPressedObserver) = Signal<String, Never>.pipe()
	let (connectionPressedSignal, connectionPressedObserver) = Signal<Void, Never>.pipe()
	let (helpPressedSignal, helpPressedObserver) = Signal<Void, Never>.pipe()
	
	// MARK: - Outputs
	
	let (navigationSignal, navigationObserver) = Signal<ItemListRoute, Never>.pipe()
	let items = Property(value: ["First", "Second", "Third"])
	
	// MARK: - Init
	
	init() {
		lifetime += itemPressedSignal
			.map(ItemListRoute.item)
			.observe(navigationObserver)
		
		lifetime += connectionPressedSignal
			.map { _ in
				let viewModel = ConfigurationViewModel()
				return .configuration(viewModel)
			}
			.observe(navigationObserver)
		
		lifetime += helpPressedSignal
			.map(value: .help)
			.observe(navigationObserver)
	}
}
```

</details>

<details>
  <summary>Coordinator</summary>
	
```swift
enum AppRoute {
	case start(ItemListViewModelType)
	case itemList(ItemListRoute)
	case configuration(ConfigurationRoute)
}

final class AppCoordinator: Coordinator, ReactiveExtensionsProvider {
	// MARK: - Properties
	
	private let navigator: StackNavigator<AppRoute>
	
	private let navigationController = UINavigationController()
	
	// MARK: - Init
	
	init() {
		navigator = StackNavigator(navigationController: navigationController)
	}
	
	// MARK: - Coordinator
	
	var rootViewController: UIViewController { navigationController }
	
	func handle(route: AppRoute) {
		switch route {
		case let .start(viewModel):
			let viewController = ItemListViewController(viewModel: viewModel)
			reactive.handle <~ viewModel.navigationSignal
				.take(duringLifetimeOf: viewController)
				.map(AppRoute.itemList)
			navigator.set([(route: route, viewController: viewController)], animated: false)
			
		case let .itemList(itemListRoute):
			handle(route: route, listRoute: itemListRoute)
			
		case let .configuration(configurationRoute):
			handle(route: route, configurationRoute: configurationRoute)
		}
	}
	
	private func handle(route: AppRoute, listRoute: ItemListRoute) {
		switch listRoute {
		case let .item(item):
			let viewController = ItemViewController(item: item)
			navigator.push(route: route, viewController: viewController, animated: true)
			
		case let .configuration(viewModel):
			let viewController = ConfigurationViewController(viewModel: viewModel)
			reactive.handle <~ viewModel.navigationSignal
				.take(duringLifetimeOf: viewController)
				.map(AppRoute.configuration)
			navigator.push(route: route, viewController: viewController, animated: true)
			
		case .help:
			let viewController = HelpViewController()
			navigator.push(route: route, viewController: viewController, animated: true)
		}
	}
	
	private func handle(route: AppRoute, configurationRoute: ConfigurationRoute) {
		// ...
	}
}
```

</details>
