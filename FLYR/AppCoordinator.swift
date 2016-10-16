//
//  AppCoordinator.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit
import Bond
import GGNLocationPicker
import MapKit

typealias LaunchOptions = [NSObject : AnyObject]?

protocol AppCoordinating: AlertOutputing, ViewControllerOutputing {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController
}

protocol ViewControllerOutputing {
    var viewControllerOutput: EventProducer<UIViewController> { get }
}

class AppCoordinator: NSObject, AppCoordinating {
    static let sharedInstance = AppCoordinator(
        authenticator: Authenticator(
            defaultContainer: CKContainer.defaultContainer()
        )
    )

    let viewControllerOutput = EventProducer<UIViewController>()
    let alertOutput = EventProducer<UIAlertController>()

    private var tabBarController: UITabBarController!
    private let authenticator: Authenticating

    init(authenticator: Authenticating) {
        self.authenticator = authenticator
        super.init()

        self.viewControllerOutput.deliverOn(.Main).observe { [unowned self] in
            self.tabBarController.presentViewController($0, animated: true, completion: nil)
            }.disposeIn(bnd_bag)

        self.alertOutput.deliverOn(.Main).observe { [unowned self] in
            self.tabBarController.presentViewController($0, animated: true, completion: nil)
            }.disposeIn(bnd_bag)
    }

    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController {
        if launchOptions == nil {
            tabBarController = resolvedTabBarController()
            return tabBarController
        } else {
            return launchOptions.map(toRootViewController)!
        }
    }

    private func toRootViewController(launchOptions: LaunchOptions) -> UIViewController {
        return UIViewController()
    }

    func locationButtonTapped() {
        let locationPicker = LocationPickerVC(annotationToShowOnLoad: preferredLocation())
        locationPicker.navigationItem.title = "Set Search Area"
        locationPicker.navigationItem.rightBarButtonItem = makeCancelButton(fore: locationPicker)
        locationPicker.didPickLocation = {
            self.save(preferredLocation: $0)
            locationPicker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }

        let vc = UINavigationController(rootViewController: locationPicker)
        tabBarController.presentViewController(vc, animated: true, completion: nil)
    }

    func addButtonTapped() {
        authenticator.authenticate { ownerReference, error in
            if let reference = ownerReference {
                let rootVC = resolvedAddFlyrVC(with: reference)
                let vc = UINavigationController(rootViewController: rootVC)
                self.viewControllerOutput.next(vc)
            } else if let error = error {
                let alert = makeAlert(from: error)
                self.alertOutput.next(alert)
            }
        }
    }

    func cancelButtonTapped() {
        tabBarController.dismissViewControllerAnimated(true, completion: nil)
    }

    func didFinishAddingFlyr() {
        tabBarController.dismissViewControllerAnimated(true, completion: nil)
    }

    func ownerReference() -> CKReference? {
        return authenticator.ownerReference()
    }

    func preferredLocation() -> MKAnnotation? {
        guard
            let dictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey("PreferredLocation"),
            let title = dictionary["title"] as? String,
            let subtitle = dictionary["subtitle"] as? String,
            let coordinate = dictionary["coordinate"],
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

    private func save(preferredLocation annotation: MKAnnotation) {
        let preferredLocation: [String: AnyObject] = [
            "title": (annotation.title!)!,
            "subtitle": (annotation.subtitle!)!,
            "coordinate": [
                "latitude": annotation.coordinate.latitude,
                "longitude": annotation.coordinate.longitude
            ]
        ]

        NSUserDefaults.standardUserDefaults().setObject(preferredLocation, forKey: "PreferredLocation")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}


func pointAnnotation(from annotation: MKAnnotation) -> MKPointAnnotation {
    let pointAnnotation = MKPointAnnotation()
    pointAnnotation.coordinate = annotation.coordinate
    pointAnnotation.title = annotation.title!
    pointAnnotation.subtitle = annotation.subtitle!
    return pointAnnotation
}
