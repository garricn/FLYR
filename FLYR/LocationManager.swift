//
//  LocationManager.swift
//  Pods
//
//  Created by Garric Nahapetian on 8/22/16.
//
//

import CoreLocation
import GGNObservable

protocol LocationManageable {
    var output: Observable<LocationResponse> { get }
    var enabledAndAuthorized: Bool { get }
    var deniedOrRestricted: Bool { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var servicesEnabled: Bool { get }
    func requestWhenInUseAuthorization(completion: @escaping (AuthorizationResponse) -> Void)
    func requestLocation(completion: @escaping (LocationResponse) -> Void)
}

enum LocationResponse {
    case didFail(Error)
    case didFailAuthorization(AuthorizationResponse)
    case didUpdateLocations([CLLocation])
}

enum AuthorizationResponse {
    case servicesNotEnabled
    case authorizationRestricted
    case authorizationDenied
    case authorizationGranted
}

class LocationManager: NSObject, LocationManageable {
    let output = Observable<LocationResponse>()
    
    var enabledAndAuthorized: Bool {
        return CLLocationManager.locationServicesEnabled()
            && CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    var deniedOrRestricted: Bool {
        return authorizationStatus == .denied
        || authorizationStatus == .restricted
    }

    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    var servicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    fileprivate let locationManger = CLLocationManager()
    fileprivate var requestWhenInUseAuthorizationCompletion: ((AuthorizationResponse) -> Void)?
    fileprivate var requestLocationCompletion: ((LocationResponse) -> Void)?

    func requestWhenInUseAuthorization(completion: @escaping (AuthorizationResponse) -> Void) {
        guard !enabledAndAuthorized else {
            return completion(.authorizationGranted)
        }

        self.requestWhenInUseAuthorizationCompletion = completion
        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()
    }
    
    func requestLocation(completion: @escaping (LocationResponse) -> Void) {
        requestWhenInUseAuthorization { response in
            switch response {
            case .authorizationGranted:
                self.requestLocationCompletion = completion
                self.locationManger.delegate = self
                self.locationManger.requestLocation()
            case .authorizationDenied:
                completion(.didFailAuthorization(.authorizationDenied))
            case .authorizationRestricted:
                completion(.didFailAuthorization(.authorizationRestricted))
            case .servicesNotEnabled:
                completion(.didFailAuthorization(.servicesNotEnabled))
            }
        }
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
            requestWhenInUseAuthorizationCompletion?(.authorizationGranted)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        requestLocationCompletion?(.didUpdateLocations(locations))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        requestLocationCompletion?(.didFail(error))
    }
}
