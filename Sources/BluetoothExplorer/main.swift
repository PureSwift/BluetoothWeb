import Foundation
import TokamakDOM
import JavaScriptKit
import BluetoothWeb

struct WebApp: App {
    var body: some Scene {
        WindowGroup("App") {
            ContentView()
        }
    }
}

struct ContentView: View {
    
    @State
    var didTouch = false
    
    @State
    var isSupported: Bool?
    
    var body: some View {
        switch isSupported {
        case .none:
            AnyView(Text("Loading..."))
                .task { await checkSupportedBrowser() }
        case .some(false):
            AnyView(UnsupportedView())
        case .some(true):
            AnyView (
                VStack(alignment: .center, spacing: nil) {
                    Text(didTouch ?  "Don't touch me\n\(BluetoothUUID().description)" : "Hello, Swift")
                    Button("Touch me") {
                        Task {
                            didTouch.toggle()
                        }
                    }
                }
            )
        }
    }
}

extension ContentView {
    
    func checkSupportedBrowser() async {
        isSupported = await WebCentral.shared?.isAvailable ?? false
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebApp.main()
