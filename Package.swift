// swift-tools-version:5.5
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
            name: "Tokamak",
            url: "https://github.com/TokamakUI/Tokamak.git",
            from: "0.9.0"
        ),
        .package(
            name: "Bluetooth",
            url: "https://github.com/PureSwift/Bluetooth.git",
            .branch("feature/async")
        ),
        .package(
            name: "GATT",
            url: "https://github.com/PureSwift/GATT.git",
            .branch("feature/async")
        ),
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
                    name: "Bluetooth",
                    package: "Bluetooth"
                ),
                .product(
                    name: "GATT",
                    package: "GATT"
                ),
            ]
        )
    ]
)
