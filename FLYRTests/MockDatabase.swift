//
//  MockDatabase.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit

@testable import FLYR

struct MockDatabase: Database {
    func perform(query: CKQuery, completion: (with: Response) -> Void) {
        let response: Response


        switch query.recordType {
        case "Flyr":
            let mockRecords = [mockRecord]
            response = .Successful(with: mockRecords)
        case "NoRecords":
            response = .Successful(with: [])
        case "Invalid":
            let error = Error(message: "Invalid Query")
            response = .NotSuccessful(with: error)
        default:
            let error = Error(message: "Unknown Error")
            response = .NotSuccessful(with: error)
        }

        completion(with: response)
    }

    func save(record: CKRecord, completion: (with: Response) -> Void) {

    }
}

let predicate = NSPredicate(value: true)

let validQuery = CKQuery(recordType: "Flyr", predicate: predicate)

let noRecordsQuery = CKQuery(recordType: "NoRecords", predicate: predicate)

let invalidQuery = CKQuery(recordType: "Invalid", predicate: predicate)
