//
//  AttributeValueCell.swift
//  
//
//  Created by Alsey Coleman Miller on 22/12/21.
//

import Foundation
import TokamakDOM
import JavaScriptKit
import BluetoothWeb

struct AttributeValueCell: View {
    
    let uuid: BluetoothUUID
    
    let attributeValue: AttributeValue
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            data
            Text(type)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(verbatim: date)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

extension AttributeValueCell {
    
    var date: String {
        return JSDate(millisecondsSinceEpoch: attributeValue.date.timeIntervalSince1970 * 1000).toUTCString()
    }
    
    var type: String {
        switch attributeValue.type {
        case .read:
            return "Read"
        case .write:
            return "Write"
        case .notification:
            return "Notification"
        }
    }
    
    var data: some View {
        // empty data
        guard attributeValue.data.isEmpty == false else {
            return AnyView(Text("Empty data"))
        }
        if let description = uuid.description(for: attributeValue.data) {
            return AnyView(Text(verbatim: description))
        } else {
            return AnyView(
                VStack(alignment: .leading, spacing: nil) {
                    Text(verbatim: "0x" + attributeValue.data.toHexadecimal())
                    Text(verbatim: "\(attributeValue.data.count) bytes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            )
        }
    }
}

internal extension BluetoothUUID {
    
    func description(for value: Data) -> String? {
        switch self {
        case .batteryLevel:
            return value.first.flatMap { $0.description + "%" }
        case .currentTime:
            return nil
        case .deviceName,
            .serialNumberString,
            .firmwareRevisionString,
            .softwareRevisionString,
            .hardwareRevisionString,
            .modelNumberString,
            .manufacturerNameString:
            return String(data: value, encoding: .utf8)
        default:
            return nil
        }
    }
}

