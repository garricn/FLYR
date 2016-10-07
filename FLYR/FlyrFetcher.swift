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
    func fetch(with operation: CKQueryOperation, and query: CKQuery)
}

struct FlyrFetcher: FlyrFetchable {
    let output = EventProducer<Flyrs>()
    let errorOutput = EventProducer<ErrorType?>()

    let database: Database

    init(database: Database) {
        self.database = database
    }

    func fetch(with operation: CKQueryOperation, and query: CKQuery) {
        database.add(operation)
        fetch(with: query)
    }

    func fetch(with query: CKQuery) {
        database.perform(query) { response in
            guard case .Successful(let records as CKRecords) = response else {
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
        image: image(from: record),
        location: location(from: record),
        startDate: startDate(from: record),
        ownerReference: ownerReference(from: record)
    )
}

func image(from record: CKRecord) -> UIImage {
    let imageAsset = record["image"] as! CKAsset
    let path = imageAsset.fileURL.path!
    return UIImage(contentsOfFile: path)!
}

func location(from record: CKRecord) -> CLLocation {
    return record["location"] as! CLLocation
}

func startDate(from record: CKRecord) -> NSDate {
    return record["startDate"] as! NSDate
}

func ownerReference(from record: CKRecord) -> CKReference {
    return record["ownerReference"] as! CKReference
}