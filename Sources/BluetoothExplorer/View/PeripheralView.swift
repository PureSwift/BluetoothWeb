//
//  PeripheralView.swift
//  
//
//  Created by Alsey Coleman Miller on 25/12/21.
//

import Foundation
import TokamakDOM
import JavaScriptKit
import BluetoothWeb

struct PeripheralView: View {
    
    @ObservedObject
    var store: Store = .shared
    
    let peripheral: Store.Peripheral
    
    var body: some View {
        List {
            if let name = scanData?.advertisementData.localName {
                Text(verbatim: name)
            }
            if services.isEmpty == false {
                ForEach(services) { service in
                    Section(header: Text(verbatim: service.uuid.description)) {
                        Text(verbatim: service.uuid.description)
                    }
                }
            }
        }
    }
}

extension PeripheralView {
    
    var title: some View {
        if let name = scanData?.advertisementData.localName {
            return Text(verbatim: name)
        } else {
            return Text("Device")
        }
    }
    
    var scanData: ScanData<WebCentral.Peripheral, WebCentral.Advertisement>? {
        store.scanResults[peripheral]
    }
    
    var services: [Service<WebCentral.Peripheral, WebCentral.AttributeID>] {
        store.services[peripheral] ?? []
    }
}
