//
//  AppCoordinator.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit

protocol AppCoordinatorProtocol {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController
}

class AppCoordinator: NSObject, AppCoordinatorProtocol {
    var tabBarController: UITabBarController!

    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController {
        guard launchOptions != nil else {
            tabBarController = resolvedTabBarController()
            return tabBarController
        }

        return launchOptions.map(toRootViewController)!
    }

    private func toRootViewController(launchOptions: LaunchOptions) -> UIViewController {
        return UIViewController()
    }

    func addButtonTapped() {
        let addFlyrVC = resolvedAddFlyrVC()
        tabBarController.presentViewController(addFlyrVC, animated: true, completion: nil)
    }

    func cancelButtonTapped() {
        tabBarController.dismissViewControllerAnimated(true, completion: nil)
    }

    func didFinishAddingFlyr() {
        tabBarController.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AppCoordinator: AddFlyrDelegate {
    func controllerDidFinish() {
        tabBarController.selectedIndex = 0
    }

    func controllerFailed(with error: ErrorType) {
    }
}
