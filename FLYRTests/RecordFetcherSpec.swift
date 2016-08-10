//
//  RecordFetcherSpec.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/6/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Quick
import Nimble
import Bond
import CloudKit

@testable import FLYR

class RecordFetcherSpec: QuickSpec {
    override func spec() {
        let subject = RecordFetcher(database: MockDatabase())
        let recordInput = Observable<CKRecord?>(nil)

        beforeEach {
            subject.recordOutput.bindTo(recordInput)
        }

        describe("By default") {
            it("fetches and outputs records") {
                expect(recordInput.value).toNot(beNil())
            }
        }
    }
}

struct MockDatabase: DatabaseProtocol {
    func performQuery(
        query: CKQuery,
        inZoneWithID zoneID: CKRecordZoneID?,
        completionHandler: ([CKRecord]?, NSError?) -> Void
    ) {
        let record = CKRecord(recordType: "Flyr")
        completionHandler([record], nil)
    }
}