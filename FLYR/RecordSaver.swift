//
//  RecordSaver.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit

protocol RecordSaveable {
    var database: Database { get }
    func save(_ record: CKRecord, _ complettion: @escaping (Response) -> Void)
}

class RecordSaver: RecordSaveable {
    let database: Database

    public init(database: Database) {
        self.database = database
    }

    func save(_ record: CKRecord, _ completion: @escaping (Response) -> Void) {
        database.save(record) { response in
            completion(response)
        }
    }
}
