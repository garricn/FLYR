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
        let _ = FeedVM(
            recordFetcher: MockRecordFetcher()
        )

        let imageInput = Observable<UIImage?>(nil)

        describe("By default") {
            it("emits an image") {
                expect(imageInput.value).toNot(beNil())
            }
        }
    }
}

struct MockRecordFetcher: RecordFetchable {
    let recordOutput: EventProducer<CKRecord>

    init() {
        recordOutput = EventProducer<CKRecord>()
    }
}
