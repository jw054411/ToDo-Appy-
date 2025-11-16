// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ToDo-Appy",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ToDoAppyCore",
            targets: ["ToDoAppyCore"]
        )
    ],
    dependencies: [
        // Add external dependencies here if needed
        // Example: .package(url: "https://github.com/example/package", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "ToDoAppyCore",
            dependencies: [],
            path: "ToDo-Appy",
            exclude: [
                "Info.plist",
                "ToDo-Appy.entitlements",
                "ToDo-Appy-macOS.entitlements",
                "Resources"
            ],
            sources: [
                "App",
                "Models",
                "ViewModels",
                "Views",
                "Services",
                "DesignSystem",
                "Utilities"
            ]
        ),
        .testTarget(
            name: "ToDoAppyTests",
            dependencies: ["ToDoAppyCore"],
            path: "Tests/ToDoAppyTests"
        )
    ]
)
