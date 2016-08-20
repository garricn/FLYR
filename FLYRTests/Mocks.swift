//
//  Mocks.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit
import Bond

@testable import FLYR

struct MockDatabase: Database {
    func perform(query: CKQuery, with completion: (Response) -> Void) {
        let mockRecords = [mockRecord]
        let response = Response.Success(with: mockRecords)
        completion(response)
    }
}

let mockQuery = CKQuery(recordType: "Flyr", predicate: NSPredicate(value: true))

var mockRecord: CKRecord {
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
    return record
}

struct MockFlyrFetcher: FlyrFetchable {
    let output = EventProducer<Flyrs>()
    let database: Database
    let query: CKQuery

    init(database: Database, query: CKQuery) {
        self.database = database
        self.query = query
    }

    func fetch() {
        output.next([mockFlyr])
    }
}

let mockFlyr = Flyr(image: mockImage)

let mockImage = UIImage(named: "photo")!