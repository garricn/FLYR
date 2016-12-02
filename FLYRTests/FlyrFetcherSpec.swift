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
        let flyrInput: Observable<Flyrs?> = Observable(nil)
        let errorInput: Observable<ErrorType?> = Observable(nil)

        subject.output.bindTo(flyrInput)
        subject.errorOutput.bindTo(errorInput)

        describe("#fetch(with:)") {
            context("Given a valid query") {
                beforeEach {
                    errorInput.lastEvent = nil
                    flyrInput.lastEvent = nil
                    subject.fetch(with: validQuery)
                }

                it("performs the query on its database and outputs the reponse") {
                    expect(flyrInput.lastEvent).toNot(beNil())
                    expect(errorInput.lastEvent).to(beNil())
                }
            }

            context("Given a valid query where the response contains no records") {
                beforeEach {
                    errorInput.lastEvent = nil
                    flyrInput.lastEvent = nil
                    subject.fetch(with: noRecordsQuery)
                }

                it("outputs an error") {
                    expect(errorInput.lastEvent).toNot(beNil())
                    expect(flyrInput.lastEvent).to(beNil())
                }
            }

            context("Given an invalid query") {
                beforeEach {
                    errorInput.lastEvent = nil
                    flyrInput.lastEvent = nil
                    subject.fetch(with: invalidQuery)
                }

                it("outputs an error") {
                    expect(errorInput.lastEvent).toNot(beNil())
                    expect(flyrInput.lastEvent).to(beNil())
                }
            }
        }
    }
}
