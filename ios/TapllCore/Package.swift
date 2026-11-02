// swift-tools-version: 5.9
import PackageDescription

// Everything that touches the native Tapll SDK lives here, with no dependency on Flutter, so the
// argument mapping can be unit-tested on the host (`swift test`). The Flutter plugin target only
// moves method-channel calls into `TapllBridge`.
let package = Package(
    name: "TapllCore",
    // macOS only so `swift test` runs on the host; the plugin targets iOS apps.
    platforms: [.iOS("16.0"), .macOS("13.0")],
    products: [
        .library(name: "TapllCore", targets: ["TapllCore"]),
    ],
    dependencies: [
        // For local work against an unreleased tapll-ios, swap in `.package(path: "<checkout>")`.
        .package(url: "https://github.com/tapll/tapll-ios", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "TapllCore",
            dependencies: [
                .product(name: "Tapll", package: "tapll-ios"),
            ]
        ),
        .testTarget(
            name: "TapllCoreTests",
            dependencies: ["TapllCore"]
        ),
    ]
)
