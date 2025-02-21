// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "KeychainSwift",
    products: [
        .library(name: "KeychainSwift", targets: ["KeychainSwift"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
          name: "KeychainSwift",
          dependencies: [],
          path: "Sources",
          exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "KeychainSwiftTests",
            dependencies: ["KeychainSwift"],
            exclude: ["ClearTests.swift"]
        )
    ],
    swiftLanguageModes: [.v6]
)
