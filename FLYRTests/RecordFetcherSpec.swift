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
        var subject: FlyrFetcher!
        let flyrInput: Observable<Flyrs?> = Observable(nil)

        describe("By default") {
            beforeEach {
                subject = FlyrFetcher(
                    database: MockDatabase(),
                    query: mockQuery
                )

                subject.output.bindTo(flyrInput)

                subject.fetch()
            }

            it("fetches and outputs Flyrs") {
                expect(flyrInput.value).toNot(beNil())
            }
        }
    }
}
