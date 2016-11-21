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
    func url(from image: UIImage) -> NSURL {
        let dirPaths = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask, true
        )
        let docsDir: AnyObject = dirPaths[0]
        let filePath = docsDir.stringByAppendingPathComponent("currentImage.png")
        UIImageJPEGRepresentation(image, 0.75)!.writeToFile(filePath, atomically: true)
        return NSURL.fileURLWithPath(filePath)
    }

    let record = CKRecord(recordType: "Flyr")
    let image = UIImage(named: "photo")!
    let fileURL = url(from: image)
    let imageAsset = CKAsset(fileURL: fileURL)
    record.setObject(imageAsset, forKey: "image")
    record.setObject(CLLocation(), forKey: "location")
    return record
}()
