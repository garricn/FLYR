//
//  MockDatabase.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit

@testable import FLYR

class MockDatabase: Database {
    func perform(_ query: CKQuery, completion: @escaping (Response) -> Void) {
        let response: Response

        switch query.recordType {
        case "Flyr":
            let mockRecords = [mockRecord]
            response = .successful(mockRecords)
        case "NoRecords":
            let error = GGNError(message: "No records found.")
            response = .notSuccessful(error)
        case "Invalid":
            let error = GGNError(message: "Invalid Query")
            response = .notSuccessful(error)
        default:
            let error = GGNError(message: "Unknown Error")
            response = .notSuccessful(error)
        }

        completion(response)
    }

    func save(_ record: CKRecord, completion: @escaping (Response) -> Void) {}

    func add_(_ operation: CKQueryOperation) {}

}

let predicate = NSPredicate(value: true)

let validQuery = CKQuery(recordType: "Flyr", predicate: predicate)

let noRecordsQuery = CKQuery(recordType: "NoRecords", predicate: predicate)

let invalidQuery = CKQuery(recordType: "Invalid", predicate: predicate)
