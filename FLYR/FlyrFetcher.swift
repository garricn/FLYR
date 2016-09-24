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
    var errorOutput: EventProducer<ErrorType?> { get }
    var database: Database { get }
    func fetch(with query: CKQuery)
}

struct FlyrFetcher: FlyrFetchable {
    let output = EventProducer<Flyrs>()
    let errorOutput = EventProducer<ErrorType?>()

    internal let database: Database

    init(database: Database) {
        self.database = database
    }

    func fetch(with query: CKQuery) {
        database.perform(query) { response in
            guard case .Successful(let records) = response else {
                if case .NotSuccessful(let error) = response { self.errorOutput.next(error) }
                return
            }

            let flyrs = records.map(toFlyr)
            self.output.next(flyrs)
        }
    }
}

struct Error: ErrorType {
    let message: String
}

func toFlyr(record: CKRecord) -> Flyr {
    return Flyr(
        image: toImage(from: record),
        location: toLocation(from: record)
    )
}

func toImage(from record: CKRecord) -> UIImage {
    let imageAsset = record["image"] as! CKAsset
    let path = imageAsset.fileURL.path!
    return UIImage(contentsOfFile: path)!
}

func toLocation(from record: CKRecord) -> CLLocation {
    return record["location"] as! CLLocation
}
