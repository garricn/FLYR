//
//  FeedVMSpec.swift
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

class FeedVMSpec: QuickSpec {
    override func spec() {
        let subject = FeedVM(
            flyrFetcher: MockFlyrFetcher()
        )

        var imageInput: [UIImage] = []

        describe("Given a flyr fetcher") {
            beforeEach {
                imageInput += subject.imageOutput.array
            }

            it("emits an array of images") {
                expect(imageInput).toNot(beNil())
            }
        }
    }
}
