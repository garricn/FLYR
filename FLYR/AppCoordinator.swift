//
//  AppCoordinator.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

protocol AppCoordinator {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController
}

struct AppCoordinatorImpl: AppCoordinator {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController {
        guard launchOptions != nil else { return resolvedFeedVC() }
        return launchOptions.map(toRootViewController)!
    }

}

// Resolvers
extension AppCoordinatorImpl {
    func resolvedFeedVC() -> FeedVC {
        return FeedVC(
            feedVM: FeedVMImpl(),
            feedView: FeedView()
        )
    }
}

func toRootViewController(launchOptions: LaunchOptions) -> UIViewController {
    return UIViewController()
}