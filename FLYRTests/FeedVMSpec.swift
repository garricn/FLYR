//
//  FeedVMSpec.swift
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

class FeedVMSpec: QuickSpec {
    override func spec() {
        let mockFlyrFetcher = MockFlyrFetcher(database: MockDatabase())
        var subject = FeedVM(
            flyrFetcher: mockFlyrFetcher,
            locationManager: MockLocationManager()
        )

        var flyrInput: Flyrs?
        var alertInput: UIAlertController?

        describe("Given a flyr fetcher and a location manager") {
            beforeEach {
                flyrInput = nil
                alertInput = nil
            }

            context("and if the location manager returns a location") {
                beforeEach {
                    subject.alertOutput.onNext { alert in
                        alertInput = alert
                    }
                    subject.refresh()
                    flyrInput = subject.output.lastEvent
                }
                it("emits an array of images") {
                    expect(flyrInput).toNot(beNil())
                    expect(alertInput).to(beNil())
                }
            }

            context("but if the location manager returns anything else") {
                beforeEach {
                    subject = FeedVM(
                        flyrFetcher: mockFlyrFetcher,
                        locationManager: MockInValidLocationManager()
                    )
                    subject.alertOutput.onNext { alert in
                        alertInput = alert
                    }
                    subject.refresh()
                    flyrInput = subject.output.lastEvent
                }

                it("emits an alert") {
                    expect(flyrInput).to(beNil())
                    expect(alertInput).toNot(beNil())
                }
            }
        }
    }
}
