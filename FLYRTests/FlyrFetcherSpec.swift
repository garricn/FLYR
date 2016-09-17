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
        let subject = FlyrFetcher(database: MockDatabase())
        let flyrInput: Observable<Flyrs?> = Observable(nil)
        let errorInput: Observable<ErrorType?> = Observable(nil)

        subject.output.bindTo(flyrInput)
        subject.errorOutput.bindTo(errorInput)

        describe("#fetch(with:)") {
            context("Given a valid query") {
                beforeEach {
                    errorInput.value = nil
                    flyrInput.value = nil
                    subject.fetch(with: validQuery)
                }

                it("performs the query on its database and outputs the reponse") {
                    expect(flyrInput.value).toNot(beNil())
                    expect(errorInput.value).to(beNil())
                }
            }

            context("Given a valid query where the response contains no records") {
                beforeEach {
                    errorInput.value = nil
                    flyrInput.value = nil
                    subject.fetch(with: noRecordsQuery)
                }

                it("outputs an error") {
                    expect(errorInput.value).toNot(beNil())
                    expect(flyrInput.value).to(beNil())
                }
            }

            context("Given an invalid query") {
                beforeEach {
                    errorInput.value = nil
                    flyrInput.value = nil
                    subject.fetch(with: invalidQuery)
                }

                it("outputs an error") {
                    expect(errorInput.value).toNot(beNil())
                    expect(flyrInput.value).to(beNil())
                }
            }
        }
    }
}
