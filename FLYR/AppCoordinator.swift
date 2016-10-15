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

typealias LaunchOptions = [NSObject : AnyObject]?

protocol AppCoordinatoring: AlertOutputing, ViewControllerOutputing {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController
}

protocol ViewControllerOutputing {
    var viewControllerOutput: EventProducer<UIViewController> { get }
}

class AppCoordinator: NSObject, AppCoordinatoring {
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
        let locationPicker = LocationPickerVC()
        locationPicker.navigationItem.title = "Set Search Area"
        locationPicker.navigationItem.rightBarButtonItem = makeCancelButton(fore: locationPicker)
        locationPicker.didPickLocation = {
            let _location = location(from: $0)
            self.save(preferredLocation: _location)
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

    func preferredLocation() -> CLLocation? {
        guard
            let _data = NSUserDefaults.standardUserDefaults().dataForKey("PreferredLocation"),
            let location = NSKeyedUnarchiver.unarchiveObjectWithData(_data) as? CLLocation
            else { return nil }
        return location
    }

    private func save(preferredLocation location: CLLocation) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(location)
        NSUserDefaults.standardUserDefaults().setValue(data, forKey: "PreferredLocation")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
