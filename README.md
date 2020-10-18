# Navigation

This library helps you to implement the MVVM-Coordinator pattern by including everything you need to do it!

#### Contents:

- [Installation](#installation)
- [Example](#example)
    - [Pure Swift + dependency injection](#pure-swift--dependency-injection)
    - [ReactiveSwift + Signals](#reactiveswift--signals)
- [Contribution](#contribution)

## Installation

### Swift Package Manager

#### Automatically in Xcode:

- Click **File > Swift Packages > Add Package Dependency...**  
- Use the package URL `https://github.com/nkristek/Navigation` to add Navigation to your project.

#### Manually in your `Package.swift` file:

```swift
.package(url: "https://github.com/nkristek/Navigation", from: "0.1.1")
```

## Usage

This library offers some convenience classes and protocols to implement the coordinator pattern. By design it is very flexible and doesn't constrain the implementation where it doesn't need to.
The following is one flavor of the coordinator pattern, but you might implement it differently:

First of all, let's start with an issue I had with MVVM on iOS: 
Where should I instantiate a `UIViewController` or call methods like `navigationController.pushViewController(:animated:)`? The viewmodel should decide when a navigation should occur, but it certainly doesn't make sense to call these methods there or even import `UIKit` in the file where the viewmodel resides.

I decided to look into the coordinator pattern and came up with the following solution:
For each viewmodel that "navigates", there should be a corresponding route. This route shall contain every piece of information needed, to perform the navigation, while staying completely UI and platform independent. Since enums are very powerful in Swift, let's use them for this task. 

Let's imagine a screen that displays a list of items (`String`) and a configuration button. After tapping an item or the configuration button the respective transition should occur.

```swift
enum ItemListRoute {
	case item(String)
	case configuration(ConfigurationViewModelType)
}
```

Whenever the viewmodel wants to perform a navigation, it calls the `handle(route:)` method on a given coordinator. The protocol for a coordinator looks like this:
```swift
public protocol Coordinator: AnyObject {
    associatedtype Route
    var rootViewController: UIViewController { get }
    func handle(route: Route)
}
```

Since protocols with `associatedtype` are kind of hard to use without making heavy use of generics, there are extensions that erase the type to either `AnyCoordinator` (strong reference) or `UnownedCoordinator` (unowned reference) by using `eraseToAnyCoordinator` or `eraseToUnownedCoordinator`. 
Since the coordinator holds a strong reference to each viewcontroller and each viewcontroller holds a strong reference to the corresponding viewmodel, the viewmodel is not allowed to keep a strong reference to the coordinator to avoid reference cycles. 

`Coordinator -> UIViewController -> ViewModel -!-> Coordinator`

Instead, the viewmodel shall receive an `UnownedCoordinator<Route>`:
```swift
typealias ItemListViewModelType = ItemListViewModelInputs & ItemListViewModelOutputs

protocol ItemListViewModelInputs {
	func itemPressed(_ item: String)
	func connectionPressed()
}

protocol ItemListViewModelOutputs {
	var items: [String] { get }
}

final class ItemListViewModel: ItemListViewModelType {
	// MARK: - Private state
	
	private let coordinator: UnownedCoordinator<ItemListRoute>
		
	// MARK: - Inputs
	
	func itemPressed(_ item: String) {
		coordinator.handle(route: .item(item))
	}
	
	func connectionPressed() {
		let viewModel = ConfigurationViewModel()
		coordinator.handle(route: .configuration(viewModel))
	}
	
	// MARK: - Outputs
	
	let (navigationSignal, navigationObserver) = Signal<ItemListRoute, Never>.pipe()
	let items = ["First", "Second", "Third"]
	
	// MARK: - Init
	
	init(coordinator: UnownedCoordinator<ItemListRoute>) {
		self.coordinator = coordinator
	}
}
```

<details>
  <summary>Nested coordinator dependency</summary>

If the `ConfigurationViewModel` itself performs navigation, just add this dependency as a separate coordinator parameter:
```swift
typealias ItemListViewModelType = ItemListViewModelInputs & ItemListViewModelOutputs

protocol ItemListViewModelInputs {
	func itemPressed(_ item: String)
	func connectionPressed()
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

Great, now our viewmodel is done. As you can clearly see, we don't have any dependency on anything UI related anymore and since the coordinator implementation is easily mocked, it is highly testable.

Now let's get started with the coordinator counterpart. First of all, since there probably will be multiple different routes that need to be handled, we'll define a more generic `AppRoute` which combines all those and provides an additional case for the starting route:
```swift
enum AppRoute {
	case start(ItemListViewModelType)
	case itemList(ItemListRoute)
	case configuration(ConfigurationRoute)
}
```

Now let's implement this route in the coordinator:
```swift
final class AppCoordinator: Coordinator {
	// MARK: - Properties
	
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
			navigationController.setViewControllers([viewController], animated: true)
			
		case let .itemList(itemListRoute):
			switch itemListRoute {
			case let .item(item):
				let viewController = ItemViewController(item: item)
				navigationController.pushViewController(viewController, animated: true)
			
			case let .configuration(viewModel):
				let viewController = ConfigurationViewController(viewModel: viewModel)
				navigationController.pushViewController(viewController, animated: true)
			}
			
		case let .configuration(configurationRoute):
			// ...
		}
	}
}
```

<details>
  <summary>StackNavigator<Route></summary>
	
There is also a `StackNavigator<Route>` which provides more functionality regarding programmatic pop behavior (like popping back to a specific route):
```swift
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
			switch listRoute {
			case let .item(item):
				let viewController = ItemViewController(item: item)
				navigator.push(route: route, viewController: viewController, animated: true)
			
			case let .configuration(viewModel):
			l	et viewController = ConfigurationViewController(viewModel: viewModel)
				navigator.push(route: route, viewController: viewController, animated: true)
			}
			
		case let .configuration(configurationRoute):
			// ...
		}
	}
}
```

</details>

In `application(_:didFinishLaunchingWithOptions:)` we only need to instantiate the `AppCoordinator` and set its `rootViewController` to the `rootViewController` property of the window.
```swift
let window = UIWindow(windowScene: windowScene)
self.window = window

let coordinator = AppCoordinator()
self.coordinator = coordinator // important to keep a reference

// pass in an unowned reference to the viewmodel with the appropriate transform to convert the ItemListRoute/ConfigurationRoute to AppRoute
let viewModel = ItemListViewModel(coordinator: coordinator.eraseToUnownedCoordinator(transform: AppRoute.itemList),
                                  configurationCoordinator: coordinator.eraseToUnownedCoordinator(transform: AppRoute.configuration))
coordinator.handle(route: .start(viewModel))

window.rootViewController = coordinator.rootViewController
window.makeKeyAndVisible()
```

Congratulations, your MVVM-C application is up and running. Since each viewmodel brings its own route, its even possible to reuse viewmodels in different flows/coordinators.

Below there are a couple of examples on for example how to use this pattern reactively. This makes it possible to decouple the viewmodel and coordinator even further by using signals.

## Example
### Pure Swift + dependency injection

<details>
  <summary>AppDelegate</summary>
	
```swift
let window = UIWindow(windowScene: windowScene)
self.window = window

let coordinator = AppCoordinator()
self.coordinator = coordinator

let viewModel = ItemListViewModel(coordinator: coordinator.eraseToUnownedCoordinator(transform: AppRoute.itemList),
                                  configurationCoordinator: coordinator.eraseToUnownedCoordinator(transform: AppRoute.configuration))
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
}

typealias ItemListViewModelType = ItemListViewModelInputs & ItemListViewModelOutputs

protocol ItemListViewModelInputs {
	func itemPressed(_ item: String)
	func connectionPressed()
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
		}
	}
	
	private func handle(route: AppRoute, configurationRoute: ConfigurationRoute) {
		// ...
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
}

typealias ItemListViewModelType = ItemListViewModelInputs & ItemListViewModelOutputs

protocol ItemListViewModelInputs {
	var itemPressedObserver: Signal<String, Never>.Observer { get }
	var connectionPressedObserver: Signal<Void, Never>.Observer { get }
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
		}
	}
	
	private func handle(route: AppRoute, configurationRoute: ConfigurationRoute) {
		// ...
	}
}
```

</details>

## Contribution

If you find a bug feel free to open an issue. Contributions are also appreciated.
