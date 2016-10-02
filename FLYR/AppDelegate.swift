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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        let frame = screenBounds
        window = UIWindow(frame: frame)
        window?.backgroundColor = .whiteColor()
        window?.rootViewController = appCoordinator.rootViewController(from: launchOptions)
        window?.makeKeyAndVisible()
        return true
    }
}

let appCoordinator = AppCoordinator()
typealias LaunchOptions = [NSObject : AnyObject]?
