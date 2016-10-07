//
//  AddFlyrVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Foundation
import Bond
import CloudKit

protocol AddFlyrVMProtocol: AlertOutputing {
    var flyrInput: EventProducer<Flyr> { get }
    var recordSaver: RecordSaveable { get }
    var responseOutput: EventProducer<Response> { get }
}

struct AddFlyrVM: AddFlyrVMProtocol {
    let flyrInput = EventProducer<Flyr>()
    let recordSaver: RecordSaveable
    let responseOutput = EventProducer<Response>()
    var alertOutput = EventProducer<UIAlertController>()

    init(recordSaver: RecordSaveable) {
        self.recordSaver = recordSaver

        flyrInput.map(toFlyrRecord).observe {
            self.recordSaver.save($0) { response in
                switch response {
                case .Successful:
                    self.responseOutput.next(response)
                case .NotSuccessful(let error):
                    let alert = makeAlert(from: error)
                    self.alertOutput.next(alert)
                }
            }
        }
    }
}

func toFlyrRecord(from flyr: Flyr) -> CKRecord {
    let image = flyr.image
    let imageURL = toURL(from: image)
    let imageAsset = CKAsset(fileURL: imageURL)
    let flyrRecord = CKRecord(recordType: "Flyr")
    flyrRecord.setObject(imageAsset, forKey: "image")

    let location = flyr.location
    flyrRecord.setObject(location, forKey: "location")

    let startDate = flyr.startDate
    flyrRecord.setObject(startDate, forKey: "startDate")

    let ownerReference = flyr.ownerReference
    flyrRecord.setObject(ownerReference, forKey: "ownerReference")

    return flyrRecord
}

func toURL(from image: UIImage) -> NSURL {
    let dirPaths = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory,
        .UserDomainMask, true
    )
    let docsDir: AnyObject = dirPaths[0]
    let filePath = docsDir.stringByAppendingPathComponent("currentImage.png")
    UIImageJPEGRepresentation(image, 0.75)!.writeToFile(filePath, atomically: true)
    return NSURL.fileURLWithPath(filePath)
}
