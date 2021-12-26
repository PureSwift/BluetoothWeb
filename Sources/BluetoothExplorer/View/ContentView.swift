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
            AnyView(Text("Loading..."))
                .task { await checkSupportedBrowser() }
        case .some(false):
            AnyView(UnsupportedView())
        case .some(true):
            if isScanning {
                AnyView(Text("Scanning for devices..."))
            } else if let peripheral = device {
                AnyView(
                    ScrollView {
                        VStack(alignment: .center, spacing: nil) {
                            // scan
                            scanButton
                            // error
                            if let error = self.error {
                                Text("⚠️ \(error.localizedDescription)")
                            }
                            // peripheral view
                            PeripheralView(peripheral: peripheral, error: $error)
                        }
                        .padding()
                    }
                )
            } else {
                AnyView(
                    scanButton
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
    
    func checkSupportedBrowser() async {
        isSupported = await WebCentral.shared?.isAvailable ?? false
    }
    
    func scan() async {
        isScanning = true
        do {
            // select device
            let peripheral = try await store.scan()
            // show device UI
            self.device = peripheral
            print("Selected \(peripheral)")
            // is scanning
            isScanning = false
            // connect and load services
            try await connect(peripheral)
        }
        catch {
            self.error = error
            isScanning = false
        }
    }
    
    func connect(_ peripheral: Store.Peripheral) async throws {
        try await store.connect(to: peripheral)
        try await store.discoverServices(for: peripheral)
        let services = store.services[peripheral] ?? []
        for service in services {
            try await store.discoverCharacteristics(for: service)
        }
    }
}
