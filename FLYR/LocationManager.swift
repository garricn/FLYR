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
    func requestLocation(completion: @escaping (LocationManagerResponse) -> Void)
}

class LocationManager: NSObject, LocationManageable {
    var enabledAndAuthorized: Bool {
        return CLLocationManager.locationServicesEnabled()
            && CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }

    func requestLocation(completion: @escaping (LocationManagerResponse) -> Void) {
        requestWhenInUseAuthorization { response in
            if case .enabledAndAuthorized = response {
                self.requestLocationCompletion = completion
                self.locationManger.delegate = self
                self.locationManger.requestLocation()
            } else if let annotation = AppCoordinator.sharedInstance.preferredLocation() {
                let _location = location(from: annotation)
                completion(.didUpdateLocations([_location]))
            } else {
                completion(response)
            }
        }
    }

    fileprivate var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    fileprivate var servicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    fileprivate let locationManger = CLLocationManager()
    fileprivate var requestWhenInUseAuthorizationCompletion: ((LocationManagerResponse) -> Void)?
    fileprivate var requestLocationCompletion: ((LocationManagerResponse) -> Void)?

    fileprivate func requestWhenInUseAuthorization(completion: @escaping (LocationManagerResponse) -> Void) {
        guard !enabledAndAuthorized else {
            return completion(.enabledAndAuthorized)
        }

        self.requestWhenInUseAuthorizationCompletion = completion
        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard CLLocationManager.locationServicesEnabled() else {
            requestWhenInUseAuthorizationCompletion?(.servicesNotEnabled)
            return
        }

        switch status {
        case .notDetermined:
            locationManger.requestWhenInUseAuthorization()
        case .denied:
            requestWhenInUseAuthorizationCompletion?(.authorizationDenied)
        case .restricted:
            requestWhenInUseAuthorizationCompletion?(.authorizationRestricted)
        case .authorizedAlways, .authorizedWhenInUse:
            requestWhenInUseAuthorizationCompletion?(.enabledAndAuthorized)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        requestLocationCompletion?(.didUpdateLocations(locations))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        requestLocationCompletion?(.didFail(error))
    }
}

typealias Locations = [CLLocation]

enum LocationManagerResponse {
    case servicesNotEnabled
    case authorizationRestricted
    case authorizationDenied
    case authorizationGranted
    case enabledAndAuthorized
    case didFail(Error)
    case didUpdateLocations(Locations)
}
