//
//  MockLocationManagers.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CoreLocation

@testable import FLYR

struct MockLocationManager: LocationManageable {
    var enabledAndAuthorized: Bool = true
    func requestLocation(completion: (response: LocationManagerResponse) -> Void) {
        completion(response: .DidUpdateLocations([CLLocation()]))
    }
}

struct MockInValidLocationManager: LocationManageable {
    var enabledAndAuthorized: Bool = false
    func requestLocation(completion: (response: LocationManagerResponse) -> Void) {
        let response = LocationManagerResponse.ServicesNotEnabled
        completion(response: response)
    }
}
