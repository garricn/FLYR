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
    let alertOutput = Observable<UIAlertController>()

    let model: Flyrs

    init(model: Flyrs) {
        self.model = model
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
