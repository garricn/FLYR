//
//  MockRecords.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import UIKit

@testable import FLYR

let mockRecordID = CKRecordID(recordName: "testRecordName")
let mockCKReference = CKReference(recordID: mockRecordID, action: .none)

let mockRecord: CKRecord = {
    let record = CKRecord(recordType: "Flyr")
    let image = UIImage(named: "testPhoto")!
    let fileURL = url(from: image)
    let imageAsset = CKAsset(fileURL: fileURL)
    record.setObject(imageAsset, forKey: "image")
    record.setObject(CLLocation(), forKey: "location")
    record.setObject(NSDate(), forKey: "startDate")
    record.setObject(mockCKReference, forKey: "ownerReference")
    return record
}()
