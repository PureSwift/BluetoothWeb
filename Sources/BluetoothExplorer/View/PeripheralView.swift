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
    
    @State
    var selection: Store.Characteristic?
    
    @Binding
    var error: Error?
    
    var body: some View {
        VStack(alignment: .center, spacing: nil) {
            // sidebar
            VStack(alignment: .leading, spacing: nil) {
                sidebar
                    .padding()
                Spacer()
            }
            // detail
            VStack(alignment: .center, spacing: nil) {
                contentView.padding()
                Spacer()
            }
        }
    }
}

extension PeripheralView {
    
    var sidebar: some View {
        VStack(alignment: .leading, spacing: nil) {
            // name
            if let name = scanData?.advertisementData.localName {
                Text(verbatim: name)
            }
            // Detail view
            statusView
            // GATT
            outlineGroup
        }
    }
    
    var contentView: some View {
        VStack(alignment: .center, spacing: nil) {
            // Detail view
            if let characteristic = self.selection {
                CharacteristicView(characteristic: characteristic, error: $error)
            } else {
                EmptyView()
            }
        }
    }
    
    var outlineGroup: some View {
        OutlineGroup(groups, children: \.children) { group in
            switch group {
            case let .service(serviceGroup):
                let uuid = serviceGroup.service.uuid
                VStack(alignment: .leading, spacing: nil) {
                    AnyView(
                        Text(verbatim: uuid.name ?? uuid.rawValue)
                    )
                }
            case let .characteristic(characteristicGroup):
                let uuid = characteristicGroup.characteristic.uuid
                VStack(alignment: .leading, spacing: nil) {
                    AnyView(
                        Button(action: {
                            select(characteristicGroup.characteristic)
                        }, label: {
                            Text(verbatim: uuid.name ?? uuid.rawValue)
                        })
                        .buttonStyle(BorderlessButtonStyle())
                    )
                    .padding()
                }
            }
        }
    }
    
    enum AttributeGroup: Equatable, Identifiable {
        
        case service(ServiceGroup)
        case characteristic(CharacteristicGroup)
        
        var id: WebCentral.AttributeID {
            switch self {
            case let .service(group):
                return group.id
            case let .characteristic(group):
                return group.id
            }
        }
        
        var uuid: BluetoothUUID {
            switch self {
            case let .service(group):
                return group.service.uuid
            case let .characteristic(group):
                return group.characteristic.uuid
            }
        }
        
        var children: [AttributeGroup]? {
            switch self {
            case let .service(group):
                return group.characteristics.map { .characteristic($0) }
            case let .characteristic(group):
                return nil
            }
        }
    }
    
    struct ServiceGroup: Equatable, Identifiable {
        
        var id: WebCentral.AttributeID {
            return service.id
        }
        
        let service: Service<WebCentral.Peripheral, WebCentral.AttributeID>
        
        let characteristics: [CharacteristicGroup]
    }
    
    struct CharacteristicGroup: Equatable, Identifiable {
        
        var id: WebCentral.AttributeID {
            return characteristic.id
        }
        
        let characteristic: Characteristic<WebCentral.Peripheral, WebCentral.AttributeID>
    }
    
    var title: some View {
        if let name = scanData?.advertisementData.localName {
            return Text(verbatim: name)
        } else {
            return Text("Device")
        }
    }
    
    var isConnected: Bool {
        store.connected.contains(peripheral)
    }
    
    var showActivity: Bool {
        store.activity[peripheral] ?? false
    }
    
    var statusView: some View {
        VStack {
            HStack {
                if isConnected {
                    Button(action: {
                        disconnect()
                    }, label: {
                        Text("Connected ✅")
                    })
                } else {
                    Button(action: {
                        Task { await connect() }
                    }, label: {
                        Text("Disconnected 🚫")
                    })
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
    
    var scanData: ScanData<WebCentral.Peripheral, WebCentral.Advertisement>? {
        store.scanResults[peripheral]
    }
    
    var groups: [AttributeGroup] {
        serviceGroups.map { .service($0) }
    }
    
    var serviceGroups: [ServiceGroup] {
        services.map {
            ServiceGroup(
                service: $0,
                characteristics: characteristics(for: $0)
            )
        }
    }
    
    var services: [Service<WebCentral.Peripheral, WebCentral.AttributeID>] {
        store.services[peripheral] ?? []
    }
    
    func characteristics(for service: Service<WebCentral.Peripheral, WebCentral.AttributeID>) -> [CharacteristicGroup] {
        let characteristics = store.characteristics[service] ?? []
        return characteristics.map {
            CharacteristicGroup(characteristic: $0)
        }
    }
    
    func select(_ characteristic: Store.Characteristic) {
        self.error = nil
        print("Selected \(characteristic.uuid.description)")
        self.selection = characteristic
    }
    
    func connect() async {
        self.error = nil
        do {
            // connect
            try await store.connect(to: peripheral)
            // discover attributes
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
        catch {
            showError(error)
        }
    }
    
    func showError(_ error: Error) {
        print(error)
        disconnect()
        self.error = error
    }
    
    func disconnect() {
        store.disconnect(peripheral)
    }
}
