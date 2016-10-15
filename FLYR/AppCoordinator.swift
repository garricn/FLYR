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

protocol AppCoordinatoring {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController
}

class AppCoordinator: NSObject, AppCoordinatoring {
    static let sharedInstance = AppCoordinator()

    private var tabBarController: UITabBarController!
    private var user: User?
    private let authenticationService = AuthenticationService(
        container: CKContainer.defaultContainer()
    )

    override init() {
        super.init()
        
        authenticationService.output.observe { recordID in
            let reference = CKReference(recordID: recordID, action: .None)
            self.user = User(ownerReference: reference)
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
        guard let user = user else { return }
        let vc = UINavigationController(rootViewController: resolvedAddFlyrVC(with: user.ownerReference))
        tabBarController.presentViewController(vc, animated: true, completion: nil)
    }

    func cancelButtonTapped() {
        tabBarController.dismissViewControllerAnimated(true, completion: nil)
    }

    func didFinishAddingFlyr() {
        tabBarController.dismissViewControllerAnimated(true, completion: nil)
    }

    func ownerReference() -> CKReference? {
        return user?.ownerReference
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
