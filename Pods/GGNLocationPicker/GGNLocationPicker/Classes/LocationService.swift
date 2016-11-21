//
//  GGNLocationPicker
//
//  LocationService.swift
//
//  Created by Garric Nahapetian on 8/22/16.
//
//

import CoreLocation
import GGNObservable

class LocationService: NSObject, CLLocationManagerDelegate {
    let authorizedOutput = Observable<Bool>()

    var enabledAndAuthorized: Bool {
        return CLLocationManager.locationServicesEnabled()
            && CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
    }

    var authorizationDenied: Bool {
        return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied
    }

    private var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    private var servicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    private let locationManger = CLLocationManager()

    func requestWhenInUse() {
        guard !authorizationDenied else {
            return authorizedOutput.emit(false)
        }

        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard CLLocationManager.locationServicesEnabled() else { return }
        switch status {
        case .NotDetermined:
            locationManger.requestWhenInUseAuthorization()
        case .Denied, .Restricted:
            break
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            authorizedOutput.emit(true)
        }
    }
}
