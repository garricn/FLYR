//
//  Database.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit

protocol Database {
    func perform(query: CKQuery, with completion: (Response) -> Void)
}

extension CKDatabase: Database {
    func perform(query: CKQuery, with completion: (Response) -> Void) {
        performQuery(query, inZoneWithID: nil) { records, error in
            guard let records = records else { return }
            let response = Response.Success(with: records)
            completion(response)
        }
    }
}

extension CKRecord: Datum {}

enum Response {
    case Success(with: Data)
}

@objc protocol Datum {}
typealias Data = [Datum]
