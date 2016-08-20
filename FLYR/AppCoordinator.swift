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

struct AppCoordinator: AppCoordinatorProtocol {
    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController {
        guard launchOptions != nil else {
            return resolvedFeedVC()
        }

        return launchOptions.map(toRootViewController)!
    }

    func toRootViewController(launchOptions: LaunchOptions) -> UIViewController {
        return UIViewController()
    }
}

// Resolvers
func resolvedFeedVC() -> FeedVC {
    return FeedVC(
        feedVM: resolvedFeedVM(),
        feedView: FeedView()
    )
}

func resolvedFeedVM() -> FeedVM {
    return FeedVM(
        flyrFetcher: FlyrFetcher(
            database: resolvedPublicDatabase(),
            query: resolvedFlyrQuery()
        )
    )
}

func resolvedPublicDatabase() -> CKDatabase {
    let container = CKContainer(identifier: "iCloud.com.flyrapp.FLYR")
    return container.publicCloudDatabase
}


func resolvedFlyrQuery() -> CKQuery {
    return CKQuery(
        recordType: "Flyr",
        predicate: NSPredicate(
            format: "TRUEPREDICATE")
    )
}
