//
//  Resolvers.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/19/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit

enum Resolved {}

extension Resolved {
    static func appCoordinator() -> AppCoordinator {
        return AppCoordinator()
    }
    
    static func authenticator() -> Authenticating {
        return Authenticator(defaultContainer: CKContainer.default())
    }
}

//func resolvedTabBarController() -> UITabBarController {
//    let feedVC = UINavigationController(rootViewController: resolvedFeedVC())
//    let profileVC = UINavigationController(rootViewController: resolvedProfileVC())
//    let viewControllers = [feedVC, profileVC]
//    let tabBarController = UITabBarController()
//    tabBarController.setViewControllers(viewControllers, animated: true)
//    return tabBarController
//}

//// MARK: - FEED
//func resolvedFeedVC() -> FlyrTableVC {
//    let feedVC = FlyrTableVC(viewModel: resolvedFeedVM())
//    feedVC.tabBarItem = UITabBarItem(title: "FEED", image: UIImage(), tag: 0)
//    feedVC.tabBarItem.accessibilityLabel = "FEED"
//    return feedVC
//}
//
//func resolvedFeedVM() -> FeedVM {
//    return FeedVM()
//}

func resolvedFlyrFetcher() -> FlyrFetchable {
    return FlyrFetcher(database: resolvedPublicDatabase())
}

// MARK: - PROFILE
func resolvedProfileVC() -> FlyrTableVC {
    let profileVC = FlyrTableVC(viewModel: resolvedProfileVM())
    profileVC.tabBarItem = UITabBarItem(title: "PROFILE", image: UIImage(), tag: 1)
    profileVC.accessibilityLabel = "PROFILE"
    return profileVC
}

func resolvedProfileVM() -> ProfileVM {
    return ProfileVM(flyrFetcher: resolvedFlyrFetcher())
}

// MARK: - ADD FLYR
func resolvedAddFlyrVC(with ownerReference: CKReference) -> AddFlyrVC {
    let addFlyrVC = AddFlyrVC(viewModel: resolvedAddFlyrVM(), ownerReference: ownerReference)
    addFlyrVC.tabBarItem = UITabBarItem(title: "POST", image: UIImage(), tag: 1)
    addFlyrVC.tabBarItem.accessibilityLabel = "POST"
    return addFlyrVC
}

func resolvedAddFlyrVM() -> AddFlyrVM {
    return AddFlyrVM(
        recordSaver: resolvedRecordSaver()
    )
}



func resolvedRecordSaver() -> RecordSaver {
    return RecordSaver(database: resolvedPublicDatabase())
}

// MARK: - CloudKit
func resolvedPublicDatabase() -> CKDatabase {
    let container = CKContainer(identifier: Private.iCloudContainerID)
    return container.publicCloudDatabase
}
