//
//  MKAnnotationExtensions.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 4/1/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import MapKit

extension MKAnnotation {
    var location: CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    var displayName: String {
        let _title = title ?? ""
        let __title = _title ?? ""
        let _subtitle = subtitle ?? ""
        let __subtitle = _subtitle ?? ""
        return "\(__title)\n\(__subtitle)"
    }
}
