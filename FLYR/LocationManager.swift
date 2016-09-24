//
//  LocationManager.swift
//  Pods
//
//  Created by Garric Nahapetian on 8/22/16.
//
//

import CoreLocation

protocol LocationManageable {
    var enabledAndAuthorized: Bool { get }
    func requestLocation(completion: (response: LocationManagerResponse) -> Void)

}

class LocationManager: NSObject, LocationManageable {
    var enabledAndAuthorized: Bool {
        return CLLocationManager.locationServicesEnabled()
            && CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
    }

    func requestLocation(completion: (response: LocationManagerResponse) -> Void) {
        requestWhenInUseAuthorization { response in
            if case .EnabledAndAuthorized = response {
                self.requestLocationCompletion = completion
                self.locationManger.delegate = self
                self.locationManger.requestLocation()
            } else {
                completion(response: response)
            }
        }
    }

    private var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    private var servicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    private let locationManger = CLLocationManager()
    private var requestWhenInUseAuthorizationCompletion: ((response: LocationManagerResponse) -> Void)?
    private var requestLocationCompletion: ((response: LocationManagerResponse) -> Void)?

    private func requestWhenInUseAuthorization(completion: (response: LocationManagerResponse) -> Void) {
        guard !enabledAndAuthorized else {
            return completion(response: .EnabledAndAuthorized)
        }

        self.requestWhenInUseAuthorizationCompletion = completion
        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()
    }

}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard CLLocationManager.locationServicesEnabled() else {
            requestWhenInUseAuthorizationCompletion?(response: .ServicesNotEnabled)
            return
        }

        switch status {
        case .NotDetermined:
            locationManger.requestWhenInUseAuthorization()
        case .Denied:
            requestWhenInUseAuthorizationCompletion?(response: .AuthorizationDenied)
        case .Restricted:
            requestWhenInUseAuthorizationCompletion?(response: .AuthorizationRestricted)
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            requestWhenInUseAuthorizationCompletion?(response: .EnabledAndAuthorized)
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        requestLocationCompletion?(response: .DidUpdateLocations(locations))
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        requestLocationCompletion?(response: .DidFail(with: error))
    }
}

typealias Locations = [CLLocation]

enum LocationManagerResponse {
    case ServicesNotEnabled
    case AuthorizationRestricted
    case AuthorizationDenied
    case AuthorizationGranted
    case EnabledAndAuthorized
    case DidFail(with: NSError)
    case DidUpdateLocations(Locations)
}
