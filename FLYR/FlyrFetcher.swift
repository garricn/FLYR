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

typealias CKRecords = [CKRecord]
typealias Flyrs = [Flyr]
protocol FlyrFetchable {
    var output: EventProducer<Flyrs> { get }
    var database: Database { get }
    var query: CKQuery { get }
    func fetch()
}

struct FlyrFetcher: FlyrFetchable {
    let output = EventProducer<Flyrs>()

    internal let database: Database
    internal let query: CKQuery

    init(database: Database, query: CKQuery) {
        self.database = database
        self.query = query
    }

    func fetch() {
        database.perform(query) { response in
            guard case .Success(let data) = response,
            let records = data as? CKRecords else {
                return
            }
            let flyrs = records.map(toFlyr)
            self.output.next(flyrs)
        }
    }
}

func toFlyr(record: CKRecord) -> Flyr {
    return Flyr(
        image: toImage(record)
    )
}
