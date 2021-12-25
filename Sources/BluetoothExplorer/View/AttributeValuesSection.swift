//
//  AttributeValuesSection.swift
//  
//
//  Created by Alsey Coleman Miller on 22/12/21.
//

import Foundation
import TokamakDOM
import JavaScriptKit
import BluetoothWeb

struct AttributeValuesSection: View {
    
    let uuid: BluetoothUUID
    
    let values: [AttributeValue]
    
    var body: some View {
        Section(header: Text("Values")) {
            ForEach(values) {
                AttributeValueCell(
                    uuid: uuid,
                    attributeValue: $0
                )
            }
        }
    }
}
