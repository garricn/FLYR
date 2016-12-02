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
    func requestLocation(_ completion: (_ response: LocationManagerResponse) -> Void) {
        completion(response: .DidUpdateLocations([CLLocation()]))
    }
}

struct MockInValidLocationManager: LocationManageable {
    var enabledAndAuthorized: Bool = false
    func requestLocation(_ completion: (_ response: LocationManagerResponse) -> Void) {
        let response = LocationManagerResponse.ServicesNotEnabled
        completion(response: response)
    }
}
