//
//  PhotoFetcher.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/6/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import UIKit
import GGNObservable

typealias CKRecords = [CKRecord]
typealias Flyrs = [Flyr]

protocol FlyrFetchable {
    var output: Observable<Flyrs> { get }
    var refreshOutput: Observable<Flyrs> { get }
    var errorOutput: Observable<Error?> { get }
    func fetch(with query: CKQuery)
    func fetch(with operation: CKQueryOperation, and query: CKQuery)
}

class FlyrFetcher: FlyrFetchable {
    let output = Observable<Flyrs>()
    let refreshOutput = Observable<Flyrs>()
    let errorOutput = Observable<Error?>()

    fileprivate let database: Database

    init(database: Database) {
        self.database = database
    }

    func fetch(with operation: CKQueryOperation, and query: CKQuery) {
        database.add_(operation)
        fetch(with: query)
    }

    func fetch(with query: CKQuery) {
        database.perform(query, completion: completion)
    }
    
    private func completion(with response: Response) {
        switch response {
        case .successful(let records):
            guard let records = records as? CKRecords else { return }
            let flyrs = records.map(toFlyr)
            output.emit(flyrs)
            refreshOutput.emit(flyrs)
        case .notSuccessful(let error):
            errorOutput.emit(error)
        }
    }
}


struct GGNError: Error {
    let message: String
}

func toFlyr(_ record: CKRecord) -> Flyr {
    return Flyr(
        image: image(from: record),
        location: location(from: record),
        startDate: startDate(from: record),
        ownerReference: ownerReference(from: record)
    )
}

func image(from record: CKRecord) -> UIImage {
    let imageAsset = record["image"] as! CKAsset
    let path = imageAsset.fileURL.path
    return UIImage(contentsOfFile: path)!
}

func location(from record: CKRecord) -> CLLocation {
    return record["location"] as! CLLocation
}

func startDate(from record: CKRecord) -> Date {
    return record["startDate"] as! Date
}

func ownerReference(from record: CKRecord) -> CKReference {
    return record["ownerReference"] as! CKReference
}
