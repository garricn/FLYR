//
//  PhotoFetcher.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/6/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import ReactiveKit

protocol PhotoFetcherProtocol {
    var imageOutput: Stream<UIImage> { get }
}

struct PhotoFetcher: PhotoFetcherProtocol {
    let imageOutput = Stream<UIImage> { observer in
        let image = UIImage(named: "photo")!

        observer.next(image)
        observer.completed()

        return NotDisposable
    }
}
