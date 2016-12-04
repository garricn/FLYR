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

    func requestLocation(completion: @escaping (LocationManagerResponse) -> Void) {
        let locations = [CLLocation()]
        completion(.didUpdateLocations(locations))
    }
}

struct MockInValidLocationManager: LocationManageable {
    var enabledAndAuthorized: Bool = false

    func requestLocation(completion: @escaping (LocationManagerResponse) -> Void) {
        let response = LocationManagerResponse.servicesNotEnabled
        completion(response)
    }
}
