//
//  LocationService.swift
//  Pods
//
//  Created by Garric Nahapetian on 8/22/16.
//
//

import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    var enabledAndAuthorized: Bool {
        return CLLocationManager.locationServicesEnabled()
            && CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
    }

    private var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    private var servicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    private let locationManger = CLLocationManager()
    private var completion: ((enabledAndAuthorized: Bool) -> Void)?

    func requestWhenInUse(with completion: (bool: Bool) -> Void) {
        self.completion = completion
        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard CLLocationManager.locationServicesEnabled() else { return }
        switch status {
        case .NotDetermined: locationManger.requestWhenInUseAuthorization()
        case .Denied, .Restricted: break
        case .AuthorizedAlways, .AuthorizedWhenInUse: completion?(enabledAndAuthorized: true)
        }
    }
}
