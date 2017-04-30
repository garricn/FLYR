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
    
    private var coordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {
        let launchReason = LaunchReason(launchOptions: launchOptions)
        let appState = AppState(launchReason: launchReason)
        let authenticator = Authenticator()
        
        coordinator = AppCoordinator(appState: appState, authenticator: authenticator)
        
        window = UIWindow()
        window?.backgroundColor = .white
        window?.rootViewController = coordinator?.rootViewController
        window?.makeKeyAndVisible()
        return true
    }
}

typealias LaunchOptions = [UIApplicationLaunchOptionsKey: Any]?

enum LaunchReason {
    case normal
    
    init(launchOptions: LaunchOptions) {
        if launchOptions == nil {
            self = .normal
        } else {
            fatalError("Handle Launch Options!")
        }
    }
}
