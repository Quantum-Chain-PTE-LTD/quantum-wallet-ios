import QvmKit
import Foundation
import RxSwift

class QvmLabelManager {
    private let keyMethodLabelsTimestamp = "qvm-label-manager-method-labels-timestamp"
    private let keyAddressLabelsTimestamp = "qvm-label-manager-address-labels-timestamp"

    private let provider: HsLabelProvider
    private let storage: QvmLabelStorage
    private let syncerStateStorage: SyncerStateStorage
    private let disposeBag = DisposeBag()

    init(provider: HsLabelProvider, storage: QvmLabelStorage, syncerStateStorage: SyncerStateStorage) {
        self.provider = provider
        self.storage = storage
        self.syncerStateStorage = syncerStateStorage
    }

    private func syncMethodLabels(timestamp: Int) {
        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyMethodLabelsTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), timestamp == lastSyncTimestamp {
            return
        }

        provider.qvmMethodLabelsSingle()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onSuccess: { [weak self] labels in
                try? self?.storage.save(qvmMethodLabels: labels)
                self?.saveMethodLabels(timestamp: timestamp)
            }, onError: { error in
                print("Method Labels sync error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    private func syncAddressLabels(timestamp: Int) {
        if let rawLastSyncTimestamp = try? syncerStateStorage.value(key: keyAddressLabelsTimestamp), let lastSyncTimestamp = Int(rawLastSyncTimestamp), timestamp == lastSyncTimestamp {
            return
        }

        provider.qvmAddressLabelsSingle()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onSuccess: { [weak self] labels in
                try? self?.storage.save(qvmAddressLabels: labels)
                self?.saveAddressLabels(timestamp: timestamp)
            }, onError: { error in
                print("Address Labels sync error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    private func saveMethodLabels(timestamp: Int) {
        try? syncerStateStorage.save(value: String(timestamp), key: keyMethodLabelsTimestamp)
    }

    private func saveAddressLabels(timestamp: Int) {
        try? syncerStateStorage.save(value: String(timestamp), key: keyAddressLabelsTimestamp)
    }
}

extension QvmLabelManager {
    func sync() {
        provider.updateStatusSingle()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onSuccess: { [weak self] status in
                self?.syncMethodLabels(timestamp: status.methodLabels)
                self?.syncAddressLabels(timestamp: status.addressLabels)
            }, onError: { error in
                print("Update Status sync error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    func methodLabel(input: Data) -> String? {
        let methodId = Data(input.prefix(4)).hs.hexString
        return (try? storage.qvmMethodLabel(methodId: methodId))?.label
    }

    func addressLabel(address: String) -> String? {
        (try? storage.qvmAddressLabel(address: address.lowercased()))?.label
    }

    func mapped(address: String) -> String {
        if let label = addressLabel(address: address) {
            return label
        }

        return address.shortened
    }

    func addressLabelMap() -> [String: String] {
        do {
            let addressLabels = try storage.allAddressLabels()
            return addressLabels.reduce(into: [String: String]()) { $0[$1.address] = $1.label }
        } catch {
            return [:]
        }
    }
}
