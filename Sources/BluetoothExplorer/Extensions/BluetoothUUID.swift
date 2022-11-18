import Foundation
import Bluetooth

extension BluetoothUUID {
    
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
