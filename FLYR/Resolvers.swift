//
//  Resolvers.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/19/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit

func resolvedTabBarController() -> UITabBarController {
    let viewControllers = [
        resolvedFeedVC()
    ]

    let tabBarController = UITabBarController()
    tabBarController.setViewControllers(
        viewControllers,
        animated: true
    )
    return tabBarController
}

// FEED
func resolvedFeedVC() -> UINavigationController {
    let feedVC = FeedVC(
        feedVM: resolvedFeedVM()
    )

    feedVC.tabBarItem = UITabBarItem(
        title: "FEED",
        image: UIImage(),
        tag: 0
    )

    feedVC.tabBarItem.accessibilityLabel = "FEED"

    return UINavigationController(
        rootViewController: feedVC
    )
}

func resolvedFeedVM() -> FeedVM {
    return FeedVM(
        flyrFetcher: resolvedFlyrFetcher(),
        locationManager: LocationManager()
    )
}

func resolvedFlyrFetcher() -> FlyrFetchable {
    return FlyrFetcher(
        database: resolvedPublicDatabase()
    )
}

func resolvedFlyrQuery() -> CKQuery {
    return CKQuery(
        recordType: "Flyr",
        predicate: NSPredicate(
            format: "TRUEPREDICATE")
    )
}

// ADD FLYR
func resolvedAddFlyrVC() -> UINavigationController {
    let addFlyrVC = AddFlyrVC(
        viewModel: resolvedAddFlyrVM()
    )

    addFlyrVC.tabBarItem = UITabBarItem(
        title: "POST",
        image: UIImage(),
        tag: 1
    )

    addFlyrVC.tabBarItem.accessibilityLabel = "POST"

    return UINavigationController(
        rootViewController: addFlyrVC
    )
}

func resolvedAddFlyrVM() -> AddFlyrVM {
    return AddFlyrVM(
        recordSaver: resolvedRecordSaver()
    )
}

func resolvedRecordSaver() -> RecordSaver {
    return RecordSaver(database: resolvedPublicDatabase())
}

// CloudKit
func resolvedPublicDatabase() -> CKDatabase {
    let container = CKContainer(identifier: Private.iCloudContainerID)
    return container.publicCloudDatabase
}
