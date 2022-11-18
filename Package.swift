// swift-tools-version:5.7
import PackageDescription
let package = Package(
    name: "BluetoothWeb",
    platforms: [.macOS(.v12)],
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
            url: "https://github.com/TokamakUI/Tokamak",
            from: "0.11.0"
        ),
        .package(
            url: "https://github.com/PureSwift/GATT",
            branch: "master"
        )
    ],
    targets: [
        .executableTarget(
            name: "BluetoothExplorer",
            dependencies: [
                .product(
                    name: "TokamakShim",
                    package: "Tokamak"
                ),
                "BluetoothWeb"
            ]
        ),
        .target(
            name: "BluetoothWeb",
            dependencies: [
                .product(
                    name: "TokamakShim",
                    package: "Tokamak"
                ),
                .product(
                    name: "GATT",
                    package: "GATT"
                ),
            ]
        )
    ]
)
