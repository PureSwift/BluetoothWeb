// swift-tools-version:5.5
import PackageDescription
let package = Package(
    name: "BluetoothWeb",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "BluetoothExplorer", targets: ["BluetoothExplorer"]),
        .library(name: "BluetoothWeb", targets: ["BluetoothWeb"])
    ],
    dependencies: [
        .package(
            name: "Tokamak",
            url: "https://github.com/TokamakUI/Tokamak",
            from: "0.9.0"
        ),/*
        .package(
            name: "Bluetooth",
            path: "../Bluetooth"
            //url: "https://github.com/PureSwift/Bluetooth.git",
            //.branch("master")
        ),*/
    ],
    targets: [
        .target(
            name: "BluetoothExplorer",
            dependencies: [
                .product(
                    name: "TokamakShim",
                    package: "Tokamak"
                ),
                "BluetoothWeb"
            ]
        ),
        /*
        .target(
            name: "Bluetooth"
        ),*/
        .target(
            name: "BluetoothWeb",
            dependencies: [
                .product(
                    name: "TokamakShim",
                    package: "Tokamak"
                ),
                /*
                .product(
                    name: "JavaScriptKit",
                    package: "JavaScriptKit"
                ),*/
            ]
        ),
        .testTarget(
            name: "BluetoothExplorerTests",
            dependencies: ["BluetoothExplorer"]
        ),
    ]
)
