//
//  Database.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit

protocol Database {
    func perform(query: CKQuery, completion: (with: Response) -> Void)
    func save(record: CKRecord, completion: (with: Response) -> Void)
}

extension CKDatabase: Database {
    func perform(query: CKQuery, completion: (with: Response) -> Void) {
        performQuery(query, inZoneWithID: nil) { records, error in
            let response: Response

            if let records = records where records.count > 0 {
                response = .Successful(with: records)
            } else {
                let _error: ErrorType
                if let error = error {
                    _error = error
                } else if records?.count == 0 {
                    _error = Error(message: "No records found.")
                } else {
                    _error = Error(message: "Unknown database error.")
                }
                response = .NotSuccessful(with: _error)
            }
            completion(with: response)
        }
    }

    func save(record: CKRecord, completion: (with: Response) -> Void) {
        saveRecord(record) { record, error in
            if error != nil {
                completion(with: .NotSuccessful(with: error!))
            } else {
                completion(with: .Successful(with: [record!]))
            }
        }
    }
}

extension CKRecord: Datum {}

@objc protocol Datum {}
typealias Data = [Datum]
