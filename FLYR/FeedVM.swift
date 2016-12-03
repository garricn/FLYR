//
//  FeedVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import GGNObservable
import CloudKit

class FeedVM: FlyrViewModeling {
    let output = Observable<Flyrs>()
    let alertOutput = Observable<UIAlertController>()
    let doneLoadingOutput = Observable<Void>()
    let flyrFetcher: FlyrFetchable
    let locationManager: LocationManageable

    init(flyrFetcher: FlyrFetchable, locationManager: LocationManageable) {
        self.flyrFetcher = flyrFetcher
        self.locationManager = locationManager

        self.flyrFetcher.output.onNext { [weak self] flyrs in
                self?.output.emit(flyrs)
                self?.doneLoadingOutput.emit()
        }

        self.flyrFetcher.errorOutput.onNext { error in
            let _error = error?.localizedDescription ?? "Unknown Error"
            let alert = makeAlert(title: "Error Fetching Flyrs", message: "Error: \(_error)")
            self.alertOutput.emit(alert)
        }
    }

    func refresh() {
        self.locationManager.requestLocation { response in
            if case .didUpdateLocations(let locations) = response {
                let query = self.makeQuery(from: locations)
                self.flyrFetcher.fetch(with: query)
            } else {
                let alert: UIAlertController

                switch response {
                case .servicesNotEnabled:
                    alert = makeAlert(
                        title: "Location Services Disabled",
                        message: "You can enable location services in Settings > Privacy."
                    )
                case .authorizationDenied:
                    alert = makePreferredLocationAlert()
                case .authorizationRestricted:
                    alert = makeAlert(
                        title: "Authorization Restricted",
                        message: "Location services are restricted on this device."
                    )
                case .didFail(let error):
                    alert = makeAlert(
                        title: "Location Services Error",
                        message: "Error: \(error)."
                    )
                default:
                    alert = makeAlert(
                        title: "Location Services Error",
                        message: "There was an error."
                    )
                }

                self.alertOutput.emit(alert)
            }
        }
    }

    fileprivate func makeQuery(from locations: [CLLocation]) -> CKQuery {
        let location = locations.last!
        let radius: CGFloat = 100000000.0
        let format = "(distanceToLocation:fromLocation:(location, %@) < %f)"
        let predicate = NSPredicate(
            format: format,
            location,
            radius
        )
        return CKQuery(recordType: "Flyr", predicate: predicate)
    }
}

func makePreferredLocationAlert() -> UIAlertController {
    let alert = makeAlert(
        title: "Authorization Denied",
        message: "You denied location services authorization."
    )
    let setPreferredLocationAction = UIAlertAction(
        title: "Set Preferred Location",
        style: .default,
        handler: { _ in AppCoordinator.sharedInstance.locationButtonTapped() })
    alert.addAction(setPreferredLocationAction)
    return alert
}

func makeAlert(from error: Error?) -> UIAlertController {
    return makeAlert(title: "Error", message: "\(error)")
}

func makeAlert(title: String?, message: String?) -> UIAlertController {
    let okAction = UIAlertAction(
        title: "OK",
        style: .default,
        handler: nil
    )
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert
    )
    alert.addAction(okAction)
    return alert
}
