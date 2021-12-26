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
                            VStack(alignment: .center, spacing: nil) {
                                scanButton
                            }
                            PeripheralView(peripheral: peripheral)
                        }
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
        .padding()
    }
    
    func checkSupportedBrowser() async {
        isSupported = await WebCentral.shared?.isAvailable ?? false
    }
    
    func scan() async {
        do {
            // select device
            let peripheral = try await store.scan()
            // show device UI
            self.device = peripheral
            print("Selected \(peripheral)")
        }
        catch { print(error) }
    }
}
