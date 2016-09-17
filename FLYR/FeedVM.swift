//
//  FeedVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond
import CloudKit

protocol FeedVMProtocol {
    var imageOutput: ObservableArray<UIImage> { get }
    var flyrFetcher: FlyrFetchable { get }
}

struct FeedVM: FeedVMProtocol {
    var imageOutput: ObservableArray<UIImage> = []
    var alertOutput = EventProducer<UIAlertController>()

    let flyrFetcher: FlyrFetchable
    let locationManager: LocationManageable

    init(flyrFetcher: FlyrFetchable, locationManager: LocationManageable) {
        self.flyrFetcher = flyrFetcher
        self.locationManager = locationManager

        self.flyrFetcher
            .output
            .map(toImages)
            .observe { self.imageOutput.extend($0) }

        self.flyrFetcher.errorOutput.observe { error in
            let alert: UIAlertController

            if let error = error {
                alert = self.makeAlert(
                    title: "Error Fetching Flyrs",
                    message: "Error: \(error)"
                )
            } else {
                alert = self.makeAlert(
                    title: "Error Fetching Flyrs",
                    message: "Unknown Error"
                )
            }

            self.alertOutput.next(alert)

        }
    }

    func refreshFeed() {
        self.locationManager.requestLocation { response in
            if case .DidUpdateLocations(let locations) = response {
                let query = self.makeQuery(from: locations)
                self.flyrFetcher.fetch(with: query)
            } else {
                let alert: UIAlertController

                switch response {
                case .ServicesNotEnabled:
                    alert = self.makeAlert(
                        title: "Location Services Disabled",
                        message: "You can enable location services in Settings > Privacy."
                    )
                case .AuthorizationDenied:
                    alert = self.makeAlert(
                        title: "Authorization Denied",
                        message: "You denied location services authorization."
                    )
                case .AuthorizationRestricted:
                    alert = self.makeAlert(
                        title: "Authorization Restricted",
                        message: "Location services are restricted on this device."
                    )
                case .DidFail(let error):
                    alert = self.makeAlert(
                        title: "Location Services Error",
                        message: "Error: \(error)."
                    )
                default:
                    alert = self.makeAlert(
                        title: "Location Services Error",
                        message: "There was an error."
                    )
                }

                self.alertOutput.next(alert)
            }
        }
    }

    private func makeQuery(from locations: [CLLocation]) -> CKQuery {
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

    private func makeAlert(title title: String?, message: String?) -> UIAlertController {
        let okAction = UIAlertAction(
            title: "OK",
            style: .Default,
            handler: nil
        )
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert
        )
        alert.addAction(okAction)
        return alert
    }
}

func toCKRecords(data: Data) -> CKRecords {
    return data as! CKRecords
}

func toImages(flyrs: Flyrs) -> [UIImage] {
    return flyrs.map(toImage)
}

func toImage(flyr: Flyr) -> UIImage {
    return flyr.image
}

let truePredicate = NSPredicate(format: "TRUEPREDICATE")
