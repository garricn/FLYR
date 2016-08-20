//
//  FlyrFetcherSpec.swift
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

class FlyrFetcherSpec: QuickSpec {
    override func spec() {
        var subject: FlyrFetcher!
        let flyrInput: Observable<Flyrs?> = Observable(nil)

        describe("FlyrFetcher") {
            context("Given a database and a query") {
                beforeEach {
                    subject = FlyrFetcher(
                        database: MockDatabase(),
                        query: mockQuery
                    )
                }

                it("sets its database and query") {
                    expect(subject.database).toNot(beNil())
                    expect(subject.query).toNot(beNil())
                }

                describe("#fetch") {
                    beforeEach {
                        subject.output.bindTo(flyrInput)
                        subject.fetch()
                    }

                    it("performs query on database and updates output") {
                        expect(flyrInput.value).toNot(beNil())
                    }
                }
            }
        }
    }
}
