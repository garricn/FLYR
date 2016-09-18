//
//  MockFlyrFetcher.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import Bond

@testable import FLYR

struct MockFlyrFetcher: FlyrFetchable {
    let output = EventProducer<Flyrs>()
    let errorOutput = EventProducer<ErrorType?>()

    let database: Database

    init(database: Database) {
        self.database = database
    }

    func fetch(with query: CKQuery) {
        output.next([mockFlyr])
    }
}

let mockFlyr = Flyr(image: mockImage)

let mockImage = UIImage(named: "photo")!
