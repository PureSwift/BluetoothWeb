//
//  CharacteristicView.swift
//  
//
//  Created by Alsey Coleman Miller on 25/12/21.
//

import Foundation
import TokamakDOM
import JavaScriptKit
import BluetoothWeb

struct CharacteristicView: View {
    
    @ObservedObject
    var store: Store = .shared
    
    let characteristic: Store.Characteristic
    
    @State
    var showSheet = false
    
    @State
    var willWriteWithResponse = true
    
    @Binding
    var error: Error?
    
    var body: some View {
        VStack {
            if actions.isEmpty == false {
                if canPerform(.read) {
                    Button("Read") {
                        Task { await read() }
                    }
                }
                if canPerform(.write) {
                    Button("Write") {
                        willWriteWithResponse = true
                        showSheet = true
                        Task { await write(Data([01,02,03])) }
                    }
                }
                if canPerform(.writeWithoutResponse) {
                    Button("Write without response") {
                        willWriteWithResponse = false
                        showSheet = true
                        Task { await write(Data([01,02,03])) }
                    }
                }
                if canPerform(.notify) {
                    Button(notifyActionTitle) {
                        Task { await notify() }
                    }
                }
            }
            if values.isEmpty == false {
                AttributeValuesSection(
                    uuid: characteristic.uuid,
                    values: values
                )
            }
        }
        .navigationTitle(title)
        .task {
            if values.isEmpty  {
                await reload()
            }
        }
    }
}

extension CharacteristicView {
    
    enum Action: CaseIterable {
        case write
        case writeWithoutResponse
        case read
        case notify
    }
    
    func canPerform(_ action: Action) -> Bool {
        let properties = characteristic.properties
        switch action {
        case .read:
            return properties.contains(.read)
        case .write:
            return properties.contains(.write)
        case .writeWithoutResponse:
            return properties.contains(.writeWithoutResponse)
        case .notify:
            return properties.contains(.notify) || properties.contains(.indicate)
        }
    }
    
    var actions: [Action] {
        return Action.allCases
            .filter { canPerform($0) } 
    }
}

extension CharacteristicView {
    
    var title: String {
        characteristic.uuid.description //?? "Characteristic"
    }
    
    var peripheral: Store.Peripheral {
        characteristic.peripheral
    }
    
    var isConnected: Bool {
        store.connected.contains(peripheral)
    }
    
    var descriptors: [Store.Descriptor] {
        store.descriptors[characteristic] ?? []
    }
    
    var showActivity: Bool {
        store.activity[peripheral] ?? false
    }
    
    var isNotifying: Bool {
        store.isNotifying[characteristic] ?? false
    }
    
    var notifyActionTitle: String {
        isNotifying ? "Stop Notifications" : "Notify"
    }
    
    var values: [AttributeValue] {
        store.characteristicValues[characteristic]?
            .values
            .sorted(by: { $0.date > $1.date })
        ?? []
    }
    
    func reload() async {
        self.error = nil
        // read value if possible
        if values.isEmpty {
            if canPerform(.read) {
                await read()
            }
        }
    }
    
    func read() async {
        self.error = nil
        do {
            if isConnected == false {
                try await store.connect(to: peripheral)
            }
            try await store.readValue(for: characteristic)
        }
        catch { showError(error) }
    }
    
    func notify() async {
        self.error = nil
        let isEnabled = !isNotifying
        do {
            if isConnected == false {
                try await store.connect(to: peripheral)
            }
            try await store.notify(isEnabled, for: characteristic)
        }
        catch { showError(error) }
    }
    
    func write(_ data: Data) async {
        self.error = nil
        do {
            if isConnected == false {
                try await store.connect(to: peripheral)
            }
            try await store.writeValue(data, for: characteristic, withResponse: willWriteWithResponse)
        }
        catch { showError(error) }
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
