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

protocol AppCoordinatorProtocol {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController
}

class AppCoordinator: NSObject, AppCoordinatorProtocol {
    static let sharedInstance = AppCoordinator()

    var tabBarController: UITabBarController!
    private var user: User?
    let authenticationService = AuthenticationService(
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
            let addFlyrVC = resolvedAddFlyrVC(with: user.ownerReference)
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

extension AppCoordinator: AddFlyrDelegate {
    func controllerDidFinish() {
        tabBarController.selectedIndex = 0
    }

    func controllerFailed(with error: ErrorType) {
    }
}
