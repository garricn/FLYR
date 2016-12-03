//
//  MockFlyrFetcher.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import CoreLocation
import GGNObservable

@testable import FLYR

struct MockFlyrFetcher: FlyrFetchable {
    let output = Observable<Flyrs>()
    let errorOutput = Observable<Error?>()

    let database: Database

    init(database: Database) {
        self.database = database
    }

    func fetch(with query: CKQuery) {
        output.emit([mockFlyr])
    }
}

let mockFlyr = Flyr(
    image: mockImage,
    location: CLLocation()
)

let mockImage = UIImage(named: "photo")!
