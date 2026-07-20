import Foundation
import ElementaryUI
import BluetoothWeb

struct PeripheralViewModel: Equatable, Hashable {

    struct Service: Equatable, Hashable {

        let uuid: String

        let characteristics: [Characteristic]
    }

    struct Characteristic: Equatable, Hashable {

        let uuid: String

        let value: String?
    }

    let id: String

    let services: [Service]
}

extension PeripheralViewModel {

    init(for peripheral: Store.Peripheral, store: Store) {
        self.id = "\(peripheral)"
        self.services = (store.services[peripheral] ?? []).map { service in
            Service(
                uuid: service.uuid.description,
                characteristics: store.characteristics[service, default: []].map { characteristic in
                    Characteristic(
                        uuid: characteristic.uuid.description,
                        value: store.characteristicValues[characteristic]?.values.last
                            .flatMap { characteristic.uuid.description(for: $0.data) }
                    )
                }
            )
        }
    }
}

@View
struct PeripheralView {

    var peripheral: PeripheralViewModel

    var body: some View {
        div {
            h2 { "Peripheral \(peripheral.id)" }
            for service in peripheral.services {
                ServiceView(service: service)
            }
        }
    }
}

@View
struct ServiceView {

    var service: PeripheralViewModel.Service

    var body: some View {
        div {
            h3 { "Service: \(service.uuid)" }
            ul {
                for characteristic in service.characteristics {
                    li {
                        span { "Characteristic: \(characteristic.uuid)" }
                        if let value = characteristic.value {
                            br()
                            span { value }
                        }
                    }
                }
            }
        }
    }
}
