import Foundation
import ElementaryUI
import BluetoothWeb

@View
struct ContentView {

    @State var isAvailable: Bool?

    @State var isScanning = false

    @State var errorMessage: String?

    @State var peripheral: PeripheralViewModel?

    var body: some View {
        div {
            h1 { "Bluetooth Explorer" }
            switch isAvailable {
            case .none:
                p { "Checking Bluetooth availability..." }
            case .some(false):
                p { "Bluetooth Web API not available" }
            case .some(true):
                button { isScanning ? "Scanning..." : "Scan" }
                    .onClick { scan() }
                if let errorMessage {
                    p { "Error: \(errorMessage)" }
                }
                if let peripheral {
                    PeripheralView(peripheral: peripheral)
                }
            }
        }
        .onAppear { checkAvailability() }
    }
}

extension ContentView {

    func checkAvailability() {
        Task {
            guard let central = WebCentral.shared else {
                isAvailable = false
                return
            }
            isAvailable = await central.isAvailable
        }
    }

    func scan() {
        guard isScanning == false else { return }
        isScanning = true
        errorMessage = nil
        peripheral = nil
        Task {
            defer { isScanning = false }
            do {
                let store = Store.shared
                let peripheral = try await store.scan()
                try await store.connect(to: peripheral)
                defer { store.disconnect(peripheral) }
                try await store.readAllCharacteristics(for: peripheral)
                self.peripheral = PeripheralViewModel(for: peripheral, store: store)
            }
            catch {
                self.errorMessage = "\(error)"
            }
        }
    }
}
