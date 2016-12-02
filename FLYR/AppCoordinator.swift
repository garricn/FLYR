//
//  AppCoordinator.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit
import GGNObservable
import GGNLocationPicker
import MapKit

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?

protocol AppCoordinating: AlertOutputing, ViewControllerOutputing {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController
}

protocol ViewControllerOutputing {
    var viewControllerOutput: Observable<UIViewController> { get }
}

class AppCoordinator: NSObject, AppCoordinating {
    static let sharedInstance = AppCoordinator(
        authenticator: Authenticator(
            defaultContainer: CKContainer.default()
        )
    )

    let viewControllerOutput = Observable<UIViewController>()
    let alertOutput = Observable<UIAlertController>()

    fileprivate var tabBarController: UITabBarController!
    fileprivate let authenticator: Authenticating

    init(authenticator: Authenticating) {
        self.authenticator = authenticator
        super.init()

        self.viewControllerOutput.onNext { [unowned self] in
            self.tabBarController.present($0, animated: true, completion: nil)
        }

        self.alertOutput.onNext { [unowned self] in
            self.tabBarController.present($0, animated: true, completion: nil)
        }
    }

    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController {
        if launchOptions == nil {
            tabBarController = resolvedTabBarController()
            return tabBarController
        } else {
            return launchOptions.map(toRootViewController)!
        }
    }

    fileprivate func toRootViewController(_ launchOptions: LaunchOptions) -> UIViewController {
        return UIViewController()
    }

    func locationButtonTapped() {
        let locationPicker = LocationPickerVC(with: preferredLocation())
        locationPicker.navigationItem.title = "Set Search Area"
        locationPicker.navigationItem.rightBarButtonItem = makeCancelButton(fore: locationPicker)
        locationPicker.didPick = {
            self.save(preferredLocation: $0)
            locationPicker.presentingViewController?.dismiss(animated: true, completion: nil)
        }

        let vc = UINavigationController(rootViewController: locationPicker)
        tabBarController.present(vc, animated: true, completion: nil)
    }

    func addButtonTapped() {
        authenticator.authenticate { ownerReference, error in
            if let reference = ownerReference {
                let rootVC = resolvedAddFlyrVC(with: reference)
                let vc = UINavigationController(rootViewController: rootVC)
                self.viewControllerOutput.emit(vc)
            } else if let error = error {
                let alert = makeAlert(from: error)
                self.alertOutput.emit(alert)
            }
        }
    }

    func cancelButtonTapped() {
        tabBarController.dismiss(animated: true, completion: nil)
    }

    func didFinishAddingFlyr() {
        tabBarController.dismiss(animated: true, completion: nil)
    }

    func ownerReference() -> CKReference? {
        return authenticator.ownerReference()
    }

    func preferredLocation() -> MKAnnotation? {
        guard
            let dictionary = UserDefaults.standard.dictionary(forKey: "PreferredLocation"),
            let title = dictionary["title"] as? String,
            let subtitle = dictionary["subtitle"] as? String,
            let coordinate = dictionary["coordinate"] as? [String: Any],
            let latitude = coordinate["latitude"] as? Double,
            let longitude = coordinate["longitude"] as? Double
            else { return nil }

        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coord
        return annotation
    }

    fileprivate func save(preferredLocation annotation: MKAnnotation) {
        let preferredLocation: [String: Any] = [
            "title": (annotation.title!)!,
            "subtitle": (annotation.subtitle!)!,
            "coordinate": [
                "latitude": annotation.coordinate.latitude,
                "longitude": annotation.coordinate.longitude
            ]
        ]

        UserDefaults.standard.set(preferredLocation, forKey: "PreferredLocation")
        UserDefaults.standard.synchronize()
    }
}


func pointAnnotation(from annotation: MKAnnotation) -> MKPointAnnotation {
    let pointAnnotation = MKPointAnnotation()
    pointAnnotation.coordinate = annotation.coordinate
    pointAnnotation.title = annotation.title!
    pointAnnotation.subtitle = annotation.subtitle!
    return pointAnnotation
}
