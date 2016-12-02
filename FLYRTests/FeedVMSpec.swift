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

        var imageInput: [UIImage] = []
        var alertInput = Observable<UIAlertController?>(nil)

        describe("Given a flyr fetcher and a location manager") {
            beforeEach {
                imageInput = []
                alertInput = Observable<UIAlertController?>(nil)
            }

            context("and if the location manager returns a location") {
                beforeEach {
                    subject.alertOutput.bindTo(alertInput)
                    subject.refreshFeed()
                    imageInput += subject.imageOutput.array
                }
                it("emits an array of images") {
                    expect(imageInput).toNot(beEmpty())
                    expect(alertInput.lastEvent).to(beNil())
                }
            }

            context("but if the location manager returns anything else") {
                beforeEach {
                    subject = FeedVM(
                        flyrFetcher: mockFlyrFetcher,
                        locationManager: MockInValidLocationManager()
                    )
                    subject.alertOutput.bindTo(alertInput)
                    subject.refreshFeed()
                    imageInput += subject.imageOutput.array
                }

                it("emits an alert") {
                    expect(alertInput.lastEvent).toNot(beNil())
                    expect(imageInput).to(beEmpty())
                }
            }
        }
    }
}
