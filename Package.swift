// swift-tools-version:6.3
import PackageDescription
let package = Package(
    name: "BluetoothWeb",
    platforms: [.macOS(.v15)],
    products: [
        .executable(
            name: "BluetoothExplorer",
            targets: ["BluetoothExplorer"]
        ),
        .library(
            name: "BluetoothWeb",
            targets: ["BluetoothWeb"]
        )
    ],
    dependencies: [
        .package(
          url: "https://github.com/swiftwasm/JavaScriptKit.git",
          .upToNextMinor(from: "0.56.1")
        ),
        .package(
            url: "https://github.com/PureSwift/GATT",
            branch: "master"
        ),
        .package(
            url: "https://github.com/elementary-swift/elementary-ui.git",
            from: "0.4.1"
        )
    ],
    targets: [
        .executableTarget(
            name: "BluetoothExplorer",
            dependencies: [
                .product(
                    name: "ElementaryUI",
                    package: "elementary-ui"
                ),
                .product(
                    name: "JavaScriptKit",
                    package: "JavaScriptKit"
                ),
                .product(
                    name: "JavaScriptEventLoop",
                    package: "JavaScriptKit"
                ),
                "BluetoothWeb"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "BluetoothWeb",
            dependencies: [
                .product(
                    name: "GATT",
                    package: "GATT"
                ),
                .product(
                    name: "JavaScriptKit",
                    package: "JavaScriptKit"
                )
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
