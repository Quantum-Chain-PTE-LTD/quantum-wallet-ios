import GRDB

class QvmLabelStorage {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
}

extension QvmLabelStorage {
    func qvmMethodLabel(methodId: String) throws -> QvmMethodLabel? {
        try dbPool.read { db in
            try QvmMethodLabel.filter(QvmMethodLabel.Columns.methodId == methodId).fetchOne(db)
        }
    }

    func save(qvmMethodLabels: [QvmMethodLabel]) throws {
        _ = try dbPool.write { db in
            try QvmMethodLabel.deleteAll(db)

            for label in qvmMethodLabels {
                try label.insert(db)
            }
        }
    }

    func allAddressLabels() throws -> [QvmAddressLabel] {
        try dbPool.read { db in
            try QvmAddressLabel.fetchAll(db)
        }
    }

    func qvmAddressLabel(address: String) throws -> QvmAddressLabel? {
        try dbPool.read { db in
            try QvmAddressLabel.filter(QvmAddressLabel.Columns.address == address).fetchOne(db)
        }
    }

    func save(qvmAddressLabels: [QvmAddressLabel]) throws {
        _ = try dbPool.write { db in
            try QvmAddressLabel.deleteAll(db)

            for label in qvmAddressLabels {
                try label.insert(db)
            }
        }
    }
}
