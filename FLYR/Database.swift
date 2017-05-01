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
                let err: Swift.Error
                
                if let error = error {
                    err = error
                } else {
                    err = Response.Error.unknown
                }
                
                response = .notSuccessful(err)
            }
            
            completion(response)
        }
    }

    func save(_ record: CKRecord, completion: @escaping (Response) -> Void) {
        self.save(record) { record, error in
            let response: Response
            
            if let record = record {
                response = .successful(record)
            } else if let error = error {
                response = .notSuccessful(error)
            } else {
                let err: Response.Error = .unknown
                response = .notSuccessful(err)
            }
            
            completion(response)
        }
    }

    func add_(_ operation: CKQueryOperation) {
        self.add(operation)
    }
}
