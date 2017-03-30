//
//  AppDelegate.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppCoordinatorDelegate {

    var window: UIWindow?
    
    private let appCoordinator = AppCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
        appCoordinator.delegate = self
        
        window = UIWindow(frame: screenBounds)
        window?.backgroundColor = .white
        window?.rootViewController = appCoordinator.rootViewController(from: launchOptions)
        window?.makeKeyAndVisible()
        return true
    }
    
    func rootViewControllerDidChange(in appCoordinator: AppCoordinator) {
        window?.rootViewController = appCoordinator.rootViewController
    }
}

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?
