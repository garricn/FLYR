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
    
    private var appCoordinator = Resolved.appCoordinator

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
        guard launchOptions == nil else {
            fatalError("Handle launch options!")
        }
        
        appCoordinator.start()
        
        window = UIWindow(frame: screenBounds)
        window?.backgroundColor = .white
        window?.rootViewController = appCoordinator.rootViewController
        window?.makeKeyAndVisible()
        return true
    }
}

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?
