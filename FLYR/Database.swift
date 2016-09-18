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
}

extension CKDatabase: Database {
    func perform(query: CKQuery, completion: (with: Response) -> Void) {
        performQuery(query, inZoneWithID: nil) { records, error in
            let response: Response

            if let records = records {
                response = .Successful(with: records)
            } else {
                response = .NotSuccessful(with: error)
            }

            completion(with: response)
        }
    }
}

extension CKRecord: Datum {}

@objc protocol Datum {}
typealias Data = [Datum]
