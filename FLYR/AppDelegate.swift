//
//  AppDelegate.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
        let frame = screenBounds
        window = UIWindow(frame: frame)
        window?.backgroundColor = .white
        window?.rootViewController = AppCoordinator.sharedInstance.rootViewController(from: launchOptions)
        window?.makeKeyAndVisible()
        return true
    }
}
