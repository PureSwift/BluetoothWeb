// swift-tools-version:6.0
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
          from: "0.31.2"
        ),
        .package(
            url: "https://github.com/PureSwift/GATT",
            branch: "master"
        ),
        .package(
            url: "https://github.com/swiftwasm/carton", 
            from: "1.0.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "BluetoothExplorer",
            dependencies: [
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
            ]
        )
    ]
)
