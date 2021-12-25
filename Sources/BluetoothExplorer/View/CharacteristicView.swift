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
    
    var body: some View {
        List {
            Text(verbatim: characteristic.uuid.description)
            Section(header: EmptyView()) {
                Text(verbatim: characteristic.uuid.description)
                Text(verbatim: characteristic.uuid.description)
            }
        }
    }
}

extension CharacteristicView {
    
    
}

