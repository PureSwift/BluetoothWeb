//
//  ContentView.swift
//  
//
//  Created by Alsey Coleman Miller on 25/12/21.
//

import Foundation
import TokamakDOM
import JavaScriptKit
import BluetoothWeb

struct ContentView: View {
    
    @ObservedObject
    var store: Store = .shared
    
    @State
    var device: WebCentral.Peripheral?
    
    @State
    var isScanning = false
    
    @State
    var isSupported: Bool?
    
    @State
    var error: Error?
    
    var body: some View {
        switch isSupported {
        case .none:
            AnyView(Text("Loading...").padding())
                .task { await checkSupportedBrowser() }
        case .some(false):
            AnyView(UnsupportedView())
        case .some(true):
            if isScanning {
                AnyView(Text("Scanning for devices..."))
                    .padding()
            } else if let peripheral = device, error == nil {
                AnyView(
                    ScrollView {
                        VStack(alignment: .center, spacing: nil) {
                            // scan
                            scanButton
                            // peripheral view
                            PeripheralView(peripheral: peripheral, error: $error)
                        }
                        .padding()
                    }
                )
            } else {
                AnyView(
                    VStack(alignment: .center, spacing: 10) {
                        scanButton
                        // error
                        if let _ = self.error {
                            errorView
                        }
                    }.padding()
                )
            }
        }
    }
}

extension ContentView {
    
    var scanButton: some View {
        Button(action: {
            Task { await scan() }
        }, label: {
            Text("Scan")
                .padding()
        })
    }
    
    var errorView: some View {
        guard let error = self.error else {
            return AnyView(EmptyView())
        }
        return AnyView(Text("⚠️ \(error.localizedDescription)"))
    }
    
    func checkSupportedBrowser() async {
        isSupported = await WebCentral.shared?.isAvailable ?? false
    }
    
    func scan() async {
        error = nil
        isScanning = true
        do {
            // select device
            let peripheral = try await store.scan()
            // show device UI
            self.device = peripheral
            print("Selected peripheral \(peripheral)")
            // is scanning
            isScanning = false
            // connect and load services
            try await connect(peripheral)
        }
        catch {
            isScanning = false
            showError(error)
        }
    }
    
    func connect(_ peripheral: Store.Peripheral) async throws {
        try await store.connect(to: peripheral)
        try await store.discoverServices(for: peripheral)
        let services = store.services[peripheral] ?? []
        for service in services {
            try await store.discoverCharacteristics(for: service)
            // try to read all characteristics
            let characteristics = store.characteristics[service] ?? []
            let readableCharacteristics = characteristics.filter { $0.properties.contains(.read) }
            for characteristic in readableCharacteristics {
                do { try await store.readValue(for: characteristic) }
                catch { print("Unable to read \(characteristic.uuid). \(error)") }
            }
        }
    }
    
    private func showError(_ error: Error) {
        print(error)
        self.error = error
    }
}
