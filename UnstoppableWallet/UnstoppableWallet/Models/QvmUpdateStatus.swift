import Foundation
import ObjectMapper

class QvmUpdateStatus: ImmutableMappable {
    let methodLabels: Int
    let addressLabels: Int

    required init(map: Map) throws {
        methodLabels = try map.value("qvm_method_labels")
        addressLabels = try map.value("address_labels")
    }
}
