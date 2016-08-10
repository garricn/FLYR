//
//  PhotoFetcher.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/6/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import UIKit
import Bond

protocol RecordFetchable {
    var recordOutput: EventProducer<CKRecord> { get }
}

struct RecordFetcher: RecordFetchable {
    let recordOutput = EventProducer<CKRecord>()

    init(database: DatabaseProtocol) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "Flyr", predicate: predicate)

        database.performQuery(query, inZoneWithID: nil) { records, error in
            guard let records = records else { return }
            let record = records.first!
            self.recordOutput.next(record)
        }
    }
}


protocol DatabaseProtocol {
    func performQuery(query: CKQuery, inZoneWithID zoneID: CKRecordZoneID?, completionHandler: ([CKRecord]?, NSError?) -> Void)
}

extension CKDatabase: DatabaseProtocol {}
