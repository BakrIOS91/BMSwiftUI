// swift-tools-version: 5.9
import PackageDescription

#if canImport(CompilerPluginSupport)
import CompilerPluginSupport
#endif

let package = Package(
    name: "BMSwiftUI",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(name: "BMSwiftUI", targets: ["BMSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        .macro(
            name: "BMSwiftUIMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "BMSwiftUI",
            dependencies: ["BMSwiftUIMacros"],
            swiftSettings: [.define("BUILD_LIBRARY_FOR_DISTRIBUTION")]
        ),
        .testTarget(
            name: "BMSwiftUITests",
            dependencies: [
                "BMSwiftUI",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
