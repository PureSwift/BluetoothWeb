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
    
    @State
    var device: ScanData<WebCentral.Peripheral, WebCentral.Advertisement>?
    
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
            } else {
                AnyView(
                    NavigationView {
                        VStack {
                            Button("Scan") {
                                Task { await scan() }
                            }
                            if let device = self.device {
                                PeripheralView(scanData: device)
                            }
                        }
                    }
                )
            }
        }
    }
}

extension ContentView {
    
    var central: WebCentral? {
        return WebCentral.shared
    }
    
    func checkSupportedBrowser() async {
        isSupported = await WebCentral.shared?.isAvailable ?? false
    }
    
    func scan() async {
        guard let central = self.central else {
            assertionFailure("Not supported")
            return
        }
        do { device = try await central.scan() }
        catch { print(error) }
    }
}
