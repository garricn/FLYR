//
//  FeedMode.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 4/1/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import MapKit

enum FeedMode: Equatable {

    case userLocation(MKAnnotation?)
    case preferred(MKAnnotation)
    case losAngeles
    
    init?(integer: Int, annotation: MKAnnotation) {
        switch integer {
        case 0: self = .userLocation(nil)
        case 1: self = .preferred(annotation)
        case 2: self = .losAngeles
        default: return nil
        }
    }
    
    static func ==(lhs: FeedMode, rhs: FeedMode) -> Bool {
        return lhs.integerValue == rhs.integerValue
    }
    
    var integerValue: Int {
        switch self {
        case .userLocation: return 0
        case .preferred: return 1
        case .losAngeles: return 2
        }
    }
    
    var displayName: String {
        switch self {
        case .userLocation: return "Current Location"
        case .preferred: return "Preferred Location"
        case .losAngeles: return "Los Angeles"
        }
    }
    
    var annotation: MKAnnotation? {
        switch self {
        case .userLocation(let annotation): return annotation
        case .preferred(let annotation): return annotation
        case .losAngeles: return losAngelesAnnotation
        }
    }
}
