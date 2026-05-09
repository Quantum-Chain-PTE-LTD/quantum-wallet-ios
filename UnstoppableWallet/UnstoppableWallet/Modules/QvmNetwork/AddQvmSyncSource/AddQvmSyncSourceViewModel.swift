import RxCocoa
import RxRelay
import RxSwift

class AddQvmSyncSourceViewModel {
    private let service: AddQvmSyncSourceService

    private let urlCautionRelay = BehaviorRelay<Caution?>(value: nil)
    private let finishRelay = PublishRelay<Void>()

    init(service: AddQvmSyncSourceService) {
        self.service = service
    }
}

extension AddQvmSyncSourceViewModel {
    var urlCautionDriver: Driver<Caution?> {
        urlCautionRelay.asDriver()
    }

    var finishSignal: Signal<Void> {
        finishRelay.asSignal()
    }

    func onChange(url: String?) {
        service.set(urlString: url ?? "")
        urlCautionRelay.accept(nil)
    }

    func onChange(basicAuth: String?) {
        service.set(basicAuth: basicAuth ?? "")
    }

    func onTapAdd() {
        do {
            try service.save()
            finishRelay.accept(())
        } catch AddQvmSyncSourceService.UrlError.alreadyExists {
            urlCautionRelay.accept(Caution(text: "add_qvm_sync_source.warning.url_exists".localized, type: .warning))
        } catch AddQvmSyncSourceService.UrlError.invalid {
            urlCautionRelay.accept(Caution(text: "add_qvm_sync_source.error.invalid_url".localized, type: .error))
        } catch {}
    }
}