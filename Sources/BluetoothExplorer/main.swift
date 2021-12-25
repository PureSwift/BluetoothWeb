import Foundation
import TokamakDOM
import JavaScriptKit
import BluetoothWeb

struct WebApp: App {
    var body: some Scene {
        WindowGroup("Bluetooth") {
            ContentView()
        }
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebApp.main()
