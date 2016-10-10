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

    func addButtonTapped() {
        if let user = user {
            let addFlyrVC = UINavigationController(
                rootViewController: resolvedAddFlyrVC(with: user.ownerReference)
            )
            tabBarController.presentViewController(addFlyrVC, animated: true, completion: nil)
        }
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
}
