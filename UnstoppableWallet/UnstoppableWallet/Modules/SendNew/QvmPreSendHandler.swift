import BigInt
import Combine
import QvmKit
import Foundation
import MarketKit
import RxSwift

class QvmPreSendHandler {
    private let token: Token
    private let adapter: ISendQuantumAdapter & IBalanceAdapter

    private let stateSubject = PassthroughSubject<AdapterState, Never>()
    private let balanceSubject = PassthroughSubject<Decimal, Never>()

    private let disposeBag = DisposeBag()

    init(token: Token, adapter: ISendQuantumAdapter & IBalanceAdapter) {
        self.token = token
        self.adapter = adapter

        adapter.balanceStateUpdatedObservable
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe { [weak self] state in
                self?.stateSubject.send(state)
            }
            .disposed(by: disposeBag)

        adapter.balanceDataUpdatedObservable
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe { [weak self] balanceData in
                self?.balanceSubject.send(balanceData.available)
            }
            .disposed(by: disposeBag)
    }
}

extension QvmPreSendHandler: IPreSendHandler {
    var state: AdapterState {
        adapter.balanceState
    }

    var statePublisher: AnyPublisher<AdapterState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var balance: Decimal {
        adapter.balanceData.available
    }

    var balancePublisher: AnyPublisher<Decimal, Never> {
        balanceSubject.eraseToAnyPublisher()
    }

    func sendData(amount: Decimal, address: String, memo _: String?) -> SendDataResult {
        guard let qvmAmount = BigUInt(amount.hs.roundedString(decimal: token.decimals)) else {
            return .invalid(cautions: [])
        }

        guard let qvmAddress = try? QvmKit.Address(userInput: address) else {
            return .invalid(cautions: [])
        }

        let transactionData = adapter.transactionData(amount: qvmAmount, address: qvmAddress)

        return .valid(sendData: .qvm(blockchainType: token.blockchainType, transactionData: transactionData))
    }
}
