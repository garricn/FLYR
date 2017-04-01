//
//  Database.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit

protocol Database {
    func perform(_ query: CKQuery, completion: @escaping (Response) -> Void)
    func save(_ record: CKRecord, completion: @escaping (Response) -> Void)
    func add_(_ operation: CKQueryOperation)
}

extension CKDatabase: Database {
    func perform(_ query: CKQuery, completion: @escaping (Response) -> Void) {
        self.perform(query, inZoneWith: nil) { records, error in
            let response: Response

            if let records = records, !records.isEmpty {
                response = .successful(records)
            } else {
                let _error: Error
                if let error = error {
                    _error = error
                } else if records?.count == 0 {
                    _error = GGNError(message: "No records found.")
                } else {
                    _error = GGNError(message: "Unknown database error.")
                }
                response = .notSuccessful(_error)
            }
            completion(response)
        }
    }

    func save(_ record: CKRecord, completion: @escaping (Response) -> Void) {
        self.save(record) { record, error in
            if error != nil {
                completion(.notSuccessful(error!))
            } else {
                completion(.successful([record!]))
            }
        }
    }

    func add_(_ operation: CKQueryOperation) {
        self.add(operation)
    }
}
