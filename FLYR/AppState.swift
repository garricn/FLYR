//
//  AppState.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import Foundation

enum AppState {
    case shouldOnboard
    case shouldStartFeed(with: FeedCoordinator.Mode)

    init?(launchOptions: LaunchOptions) {
        if launchOptions == nil {
            let hasOnboarded = UserDefaults.standard.bool(forKey: "hasOnboarded")

            if hasOnboarded {
                self = .shouldStartFeed(with: .userLocation)
            } else {
                self = .shouldOnboard
            }
        } else {
            fatalError("Handle launch options!")
        }
    }
}
