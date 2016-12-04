//
//  FlyrFetcherSpec.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/6/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Quick
import Nimble
import GGNObservable
import CloudKit

@testable import FLYR

class FlyrFetcherSpec: QuickSpec {
    override func spec() {
        let subject = FlyrFetcher(database: MockDatabase())
        var flyrInput: Flyrs = []
        var errorInput: Error?

        subject.output.onNext { flyrs in
            flyrInput = flyrs
        }

        subject.errorOutput.onNext { error in
            errorInput = error
        }

        describe("#fetch(with:)") {
            context("Given a valid query") {
                beforeEach {
                    flyrInput = []
                    errorInput = nil
                    subject.fetch(with: validQuery)
                }

                it("performs the query on its database and outputs the reponse") {
                    expect(flyrInput).toNot(beEmpty())
                    expect(errorInput).to(beNil())
                }
            }

            context("Given a valid query where the response contains no records") {
                beforeEach {
                    flyrInput = []
                    errorInput = nil
                    subject.fetch(with: noRecordsQuery)
                }

                it("outputs an error") {
                    expect(flyrInput).to(beEmpty())
                    expect(errorInput).toNot(beNil())
                }
            }

            context("Given an invalid query") {
                beforeEach {
                    flyrInput = []
                    errorInput = nil
                    subject.fetch(with: invalidQuery)
                }

                it("outputs an error") {
                    expect(flyrInput).to(beEmpty())
                    expect(errorInput).toNot(beNil())
                }
            }
        }
    }
}
