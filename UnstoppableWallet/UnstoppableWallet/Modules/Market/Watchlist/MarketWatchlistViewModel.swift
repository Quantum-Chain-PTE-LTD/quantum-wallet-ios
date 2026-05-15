import Combine
import Foundation
import HsExtensions
import MarketKit

class MarketWatchlistViewModel: ObservableObject {
    private let marketKit = Core.shared.marketKit
    private let currencyManager = Core.shared.currencyManager
    private let watchlistManager = Core.shared.watchlistManager
    private let userDefaultsStorage = Core.shared.userDefaultsStorage
    private let appManager = Core.shared.appManager
    private var cancellables = Set<AnyCancellable>()
    private var tasks = Set<AnyTask>()

    private var coinUids = [String]()

    private var internalState: State = .loading {
        didSet {
            syncState()
        }
    }

    @Published var state: State = .loading

    @Published var sortBy: WatchlistSortBy {
        didSet {
            stat(page: .markets, section: .watchlist, event: .switchSortType(sortType: sortBy.statSortType))
            syncState()
            watchlistManager.sortBy = sortBy
        }
    }

    @Published var timePeriod: WatchlistTimePeriod {
        didSet {
            stat(page: .markets, section: .watchlist, event: .switchPeriod(period: timePeriod.statPeriod))
            syncState()

            if timePeriod != oldValue {
                watchlistManager.timePeriod = timePeriod
            }
        }
    }

    init() {
        sortBy = watchlistManager.sortBy
        timePeriod = watchlistManager.timePeriod

        watchlistManager.$timePeriod
            .sink { [weak self] timePeriod in
                self?.timePeriod = timePeriod
            }
            .store(in: &cancellables)

    }

    private func syncCoinUids() {
        let coinUids = watchlistManager.coinUids

        if case .loaded = internalState, coinUids == self.coinUids {
            return
        }

        self.coinUids = coinUids

        if case let .loaded(marketInfos) = internalState {
            let newMarketInfos = marketInfos.filter { marketInfo in
                coinUids.contains(marketInfo.fullCoin.coin.uid)
            }

            if newMarketInfos.count == coinUids.count {
                internalState = .loaded(marketInfos: newMarketInfos)
                return
            }
        }

        syncMarketInfos()
    }

    private func syncMarketInfos() {
        tasks = Set()

        Task { [weak self] in
            await self?._syncMarketInfos()
        }.store(in: &tasks)
    }

    private func _syncMarketInfos() async {
        if coinUids.isEmpty {
            await MainActor.run { [weak self] in
                self?.internalState = .loaded(marketInfos: [])
            }
            return
        }

        if case .failed = internalState {
            await MainActor.run { [weak self] in
                self?.internalState = .loading
            }
        }

        do {
            let marketInfos = try await marketKit.marketInfos(coinUids: coinUids, currencyCode: currency.code)

            let marketInfoMap = marketInfos.reduce(into: [String: MarketInfo]()) { $0[$1.fullCoin.coin.uid] = $1 }
            let orderedMarketInfos = coinUids.compactMap { marketInfoMap[$0] }

            await MainActor.run { [weak self] in
                self?.internalState = .loaded(marketInfos: orderedMarketInfos)
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.internalState = .failed(error: error)
            }
        }
    }

    private func syncState() {
        switch internalState {
        case .loading:
            state = .loading
        case let .loaded(marketInfos):
            state = .loaded(marketInfos: marketInfos.sorted(sortBy: sortBy, timePeriod: timePeriod))
        case let .failed(error):
            state = .failed(error: error)
        }
    }
}

extension MarketWatchlistViewModel {
    var currency: Currency {
        currencyManager.baseCurrency
    }

    var timePeriods: [WatchlistTimePeriod] {
        watchlistManager.timePeriods
    }

    func load() {
        currencyManager.$baseCurrency
            .sink { [weak self] _ in
                self?.syncMarketInfos()
            }
            .store(in: &cancellables)

        appManager.willEnterForegroundPublisher
            .sink { [weak self] in self?.syncMarketInfos() }
            .store(in: &cancellables)

        watchlistManager.coinUidsPublisher
            .sink { [weak self] _ in self?.syncCoinUids() }
            .store(in: &cancellables)

        syncCoinUids()
    }

    func refresh() async {
        await _syncMarketInfos()
    }

    func remove(coinUid: String) {
        watchlistManager.remove(coinUid: coinUid)
        stat(page: .markets, section: .watchlist, event: .removeFromWatchlist(coinUid: coinUid))
    }

    func move(source: IndexSet, destination: Int) {
        guard case let .loaded(marketInfos) = internalState else {
            return
        }

        var newCoinUids = coinUids
        var newMarketInfos = marketInfos

        newCoinUids.move(fromOffsets: source, toOffset: destination)
        newMarketInfos.move(fromOffsets: source, toOffset: destination)

        coinUids = newCoinUids
        internalState = .loaded(marketInfos: newMarketInfos)

        watchlistManager.set(coinUids: coinUids)
    }
}

extension MarketWatchlistViewModel {
    enum State {
        case loading
        case loaded(marketInfos: [MarketInfo])
        case failed(error: Error)
    }
}
