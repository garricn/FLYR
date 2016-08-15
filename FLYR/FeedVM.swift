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
    var imageOutput: ObservableArray<UIImage> { get }
}

struct FeedVM: FeedVMProtocol {
    var imageOutput: ObservableArray<UIImage> = []

    init(flyrFetcher: FlyrFetchable) {
        flyrFetcher
            .output
            .map(toImages)
            .observe { self.imageOutput.extend($0) }

        flyrFetcher.fetch()
    }
}

func toCKRecords(data: Data) -> CKRecords {
    return data as! CKRecords
}

func toImages(flyrs: Flyrs) -> [UIImage] {
    return flyrs.map(toImage)
}

func toImage(flyr: Flyr) -> UIImage {
    return flyr.image
}

func toImage(record: CKRecord) -> UIImage {
    let imageAsset = record["image"] as! CKAsset
    let path = imageAsset.fileURL.path!
    return UIImage(contentsOfFile: path)!
}
