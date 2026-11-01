// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NovaStack",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "NovaStack", targets: ["NovaStack"])
    ],
    targets: [
        .executableTarget(
            name: "NovaStack",
            path: "Sources/NovaStack"
        )
    ]
)
