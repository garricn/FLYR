//
//  Flyr.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CoreLocation
import CloudKit

protocol FlyrProtocol {
    var image: UIImage { get }
}

struct Flyr: FlyrProtocol {
    let image: UIImage
    let location: CLLocation
    let startDate: Date
    let ownerReference: CKReference
    
    init(image: UIImage, location: CLLocation, startDate: Date, ownerReference: CKReference) {
        self.image = image
        self.location = location
        self.startDate = startDate
        self.ownerReference = ownerReference
    }
    
    init?(record: CKRecord) {
        guard let location = record["location"] as? CLLocation
            , let startDate = record["startDate"] as? Date
            , let ownerReference = record["ownerReference"] as? CKReference
            , let asset = record["image"] as? CKAsset
            , let image = UIImage(contentsOfFile: asset.fileURL.path)
        
            else { return nil }
        
        self.init(image: image, location: location, startDate: startDate, ownerReference: ownerReference)
    }
}
