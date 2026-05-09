import GRDB

class QvmSyncSourceStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
}

extension QvmSyncSourceStorage {
    func getAll() throws -> [QvmSyncSourceRecord] {
        try dbPool.read { db in
            try QvmSyncSourceRecord.fetchAll(db)
        }
    }

    func records(blockchainTypeUid: String) throws -> [QvmSyncSourceRecord] {
        try dbPool.read { db in
            try QvmSyncSourceRecord.filter(QvmSyncSourceRecord.Columns.blockchainTypeUid == blockchainTypeUid).fetchAll(db)
        }
    }

    func save(record: QvmSyncSourceRecord) throws {
        _ = try dbPool.write { db in
            try record.insert(db)
        }
    }

    func delete(blockchainTypeUid: String, url: String) throws {
        _ = try dbPool.write { db in
            try QvmSyncSourceRecord.filter(QvmSyncSourceRecord.Columns.blockchainTypeUid == blockchainTypeUid && QvmSyncSourceRecord.Columns.url == url).deleteAll(db)
        }
    }
}
