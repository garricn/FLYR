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

    init() {
    }

    func refresh() {}

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
        handler: { _ in
//            AppCoordinator.sharedInstance.locationButtonTapped()
    })
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
