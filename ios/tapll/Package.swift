// swift-tools-version: 5.9
import PackageDescription

// Flutter's Swift Package Manager plugin integration (Flutter >= 3.24,
// `flutter config --enable-swift-package-manager`). The Tapll iOS SDK has no CocoaPods spec, so
// Swift Package Manager is required on iOS; see README "Install".
//
// The native SDK dependency is declared in ../TapllCore/Package.swift: a local checkout
// during development, `https://github.com/tapll/tapll-ios` from 0.5.0 at release.
let package = Package(
    name: "tapll",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "tapll", targets: ["tapll"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(path: "../TapllCore"),
    ],
    targets: [
        .target(
            name: "tapll",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "TapllCore", package: "TapllCore"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
