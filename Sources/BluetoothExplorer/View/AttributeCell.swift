//
//  AttributeCell.swift
//  
//
//  Created by Alsey Coleman Miller on 19/12/21.
//

import Foundation
import TokamakDOM
import JavaScriptKit
import BluetoothWeb

struct AttributeCell: View {
    
    let uuid: BluetoothUUID
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            Text(uuid.rawValue)
        }
    }
}
