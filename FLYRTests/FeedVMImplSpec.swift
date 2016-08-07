//
//  FeedVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/6/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Quick
import Nimble
import ReactiveKit

@testable import FLYR

class FeedVMImplSpec: QuickSpec {
    override func spec() {
        let imageInput: Property<UIImage?> = Property(nil)

        beforeEach {
            let subject = FeedVMImpl(
                photoFetcher: MockPhotoFetcher()
            )

            subject.imageOutput.bindTo(imageInput)
        }

        describe("By default") {
            it("emits an image") {
                expect(imageInput.value).toNot(beNil())
            }
        }
    }
}

struct MockPhotoFetcher: PhotoFetcherProtocol {
    let imageOutput = Stream<UIImage> { observer in
        let image = UIImage(named: "photo")!

        observer.next(image)
        observer.completed()

        return NotDisposable
    }
}
