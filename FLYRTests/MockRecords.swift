//
//  MockRecords.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import UIKit

let mockRecord: CKRecord = {
    func url(from image: UIImage) -> URL {
        let dirPaths = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask, true
        )
        let docsDir: AnyObject = dirPaths[0] as AnyObject
        let filePath = docsDir.appendingPathComponent("currentImage.png")
        try? UIImageJPEGRepresentation(image, 0.75)!.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
        return URL(fileURLWithPath: filePath)
    }

    let record = CKRecord(recordType: "Flyr")
    let image = UIImage(named: "photo")!
    let fileURL = url(from: image)
    let imageAsset = CKAsset(fileURL: fileURL)
    record.setObject(imageAsset, forKey: "image")
    record.setObject(CLLocation(), forKey: "location")
    return record
}()
