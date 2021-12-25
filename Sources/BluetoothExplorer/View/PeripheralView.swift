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
        ScrollView {
            VStack {
                if let name = scanData?.advertisementData.localName {
                    Text(verbatim: name)
                }
                OutlineGroup(groups, children: \.children) { group in
                    switch group {
                    case let .service(serviceGroup):
                        AnyView(
                            Text(verbatim: serviceGroup.service.uuid.description)
                        )
                    case let .characteristic(characteristicGroup):
                        AnyView(
                            NavigationLink(
                                characteristicGroup.characteristic.uuid.description,
                                destination: CharacteristicView(characteristic: characteristicGroup.characteristic)
                            )
                        )
                    }
                }
            }
        }
    }
}

extension PeripheralView {
    
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
        
        var uuid: WebCentral.AttributeID {
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
    
    func connect() async {
        do {
            try await store.connect(to: peripheral)
            try await store.discoverServices(for: peripheral)
            let peripherals = store.services[peripheral] ?? []
            for service in peripherals {
                try await store.discoverCharacteristics(for: service)
            }
            
        }
        catch {
            print(error)
        }
    }
}
