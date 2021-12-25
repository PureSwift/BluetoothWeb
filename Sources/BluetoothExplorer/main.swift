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
    var devices = [WebCentral.Peripheral]()
    
    @State
    var isScanning = false
    
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
            if isScanning {
                AnyView(Text("Scanning for devices"))
            } else {
                VStack {
                    Button("Scan") {
                        Task { await scan() }
                    }
                    List {
                        ForEach(devices) { device in
                            Text(verbatim: device.id)
                        }
                    }
                    /*
                    NavigationView {
                        List {
                            ForEach(devices) { device in
                                Text(verbatim: device.id)
                                /*
                                NavigationLink(
                                    destination: Text(verbatim: device.id),
                                    label: {
                                        Text(verbatim: device.id)
                                    }
                                )*/
                            }
                        }
                    }*/
                }
                .navigationTitle("Central")
            }
        }
    }
}

extension ContentView {
    
    func checkSupportedBrowser() async {
        isSupported = await WebCentral.shared?.isAvailable ?? false
    }
    
    func scan() async {
        devices = []
        do {
            /*
            let stream = try await WebCentral.shared!.scan()
            for try await device in stream {
                devices.append(device)
            }*/
            devices = try await WebCentral.shared!.scan()
        }
        catch {
            print(error)
        }
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebApp.main()
