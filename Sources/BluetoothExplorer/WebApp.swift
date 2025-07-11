import Foundation
import JavaScriptEventLoop
import JavaScriptKit
import BluetoothWeb

@main
struct WebApp {
    
    static func main() {
        JavaScriptEventLoop.installGlobalExecutor()
        Task {
            guard await checkBluetooth() else {
                append("Bluetooth Web API not available")
                return
            }
            setupPage()
        }
    }
}

extension WebApp {
    
    static func setupPage() {
        button("Scan") {
            try await scan()
        }
    }
    
    static func checkBluetooth() async -> Bool {
        guard let central = WebCentral.shared, await central.isAvailable else {
            return false
        }
        return true
    }
    
    static func scan() async throws {
        let store = Store.shared
        let peripheral = try await Store.shared.scan()
        try await store.connect(to: peripheral)
        defer {
            store.disconnect(peripheral)
        }
        try await store.readAllCharacteristics(for: peripheral)
        showScanResults(for: peripheral)
    }
    
    static func showScanResults(for peripheral: Store.Peripheral) {
        let store = Store.shared
        do {
            append("Peripheral \(peripheral)")
            let services = store.services[peripheral] ?? []
            for service in services {
                append("Service: \(service.uuid)")
                let characteristics = store.characteristics[service, default: []]
                for characteristic in characteristics {
                    append("Characteristic: \(characteristic.uuid)")
                    guard characteristic.properties.contains(.read),
                        let cache = store.characteristicValues[characteristic],
                        let value = cache.values.last,
                        let description = characteristic.uuid.description(for: value.data) else {
                        continue
                    }
                    append(description)
                }
            }
        }
    }
    
    static func alert(_ message: String) {
        let alert = JSObject.global.alert.function!
        _ = JSClosure { _ in
            alert(message)
            return .undefined
        }
    }
    
    static func button(_ title: String, action: @escaping () async throws -> ()) {
        let document = JSObject.global.document
        let asyncButtonElement = document.createElement("button")
        asyncButtonElement.innerText = .string(JSString(title))
        asyncButtonElement.onclick = .object(
            JSClosure { _ in
                Task {
                    do {
                        try await action()
                    }
                    catch {
                        alert("Error: \(error)")
                    }
                }
                return .undefined
            }
        )
    }
    
    static func append(_ string: String) {
        let document = JSObject.global.document
        let divElement = document.createElement("div")
        divElement.innerText = .string(.init(string))
        _ = document.body.appendChild(divElement)
    }
}
