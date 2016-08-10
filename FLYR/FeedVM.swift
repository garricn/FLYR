//
//  FeedVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond
import CloudKit

protocol FeedVMProtocol {
    var imageOutput: EventProducer<UIImage> { get }
}

struct FeedVM: FeedVMProtocol {
    var imageOutput = EventProducer<UIImage>()

    init(recordFetcher: RecordFetchable) {
        imageOutput = recordFetcher.recordOutput.map(toImage)
    }
}

func toImage(record: CKRecord) -> UIImage {
    let imageAsset = record["image"] as! CKAsset
    let path = imageAsset.fileURL.path!
    return UIImage(contentsOfFile: path)!
}