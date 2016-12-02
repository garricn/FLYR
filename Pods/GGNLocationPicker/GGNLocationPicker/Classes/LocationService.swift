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
            && CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }

    var authorizationDenied: Bool {
        return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied
    }

    fileprivate var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    fileprivate var servicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    fileprivate let locationManger = CLLocationManager()

    func requestWhenInUse() {
        guard !authorizationDenied else {
            return authorizedOutput.emit(false)
        }

        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard CLLocationManager.locationServicesEnabled() else { return }
        switch status {
        case .notDetermined:
            locationManger.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            authorizedOutput.emit(true)
        }
    }
}
