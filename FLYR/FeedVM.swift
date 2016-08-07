//
//  FeedVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import ReactiveKit
import UIKit

protocol FeedVMProtocol {
    var imageOutput: Stream<UIImage> { get }
}

struct FeedVM: FeedVMProtocol {
    let imageOutput: Stream<UIImage>

    init(photoFetcher: PhotoFetcher) {
        imageOutput = photoFetcher.imageOutput
    }
}
