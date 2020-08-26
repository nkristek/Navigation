// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [
        .macOS(.v10_15), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "Navigation", targets: ["Navigation"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Navigation", dependencies: []),
        .testTarget(name: "NavigationTests", dependencies: ["Navigation"]),
    ],
    swiftLanguageVersions: [.v5]
)
