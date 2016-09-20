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
    func save(record: CKRecord, with complettion: (Response) -> Void)
}

struct RecordSaver: RecordSaveable {
    let database: Database

    func save(record: CKRecord, with completion: (Response) -> Void) {
        database.save(record) { response in
            completion(response)
        }
    }
}
