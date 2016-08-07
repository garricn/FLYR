//
//  PhotoFetcherImplSpec.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/6/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Quick
import Nimble
import ReactiveKit
import UIKit

@testable import FLYR

class PhotoFetcherImplSpec: QuickSpec {
    override func spec() {
        let subject = PhotoFetcher()
        let imageInput: Property<UIImage?> = Property(nil)

        beforeEach {
            subject.imageOutput.bindTo(imageInput)
        }

        describe("By default") {
            it("outputs an image") {
                expect(imageInput.value).toNot(beNil())
            }
        }
    }
}
