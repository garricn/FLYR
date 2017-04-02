//
//  Globals.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/15/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

// MARK: - Properties

// MARK: Screen

let screenBounds = UIScreen.main.bounds
let screenWidth = screenBounds.width
let screenHeight = screenBounds.height

// MARK: Locations

let losAngelesCoordinate = CLLocationCoordinate2D(latitude: 34.0432464, longitude: -118.267463)
var losAngelesAnnotation: MKAnnotation {
    let annotation = MKPointAnnotation()
    annotation.coordinate = losAngelesCoordinate
    annotation.title = "Los Angeles, CA"
    annotation.subtitle = "Best City in the World!"
    return annotation
}

// MARK: - Functions
func rowHeight(from image: UIImage) -> CGFloat {
    let ratio = image.size.height / image.size.width
    return UIScreen.main.bounds.width * ratio
}
