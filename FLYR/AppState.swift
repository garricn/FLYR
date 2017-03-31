//
//  AppState.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import Foundation

struct AppState {
    var isExistingUser: Bool {
        return UserDefaults.standard.bool(forKey: "isExistingUser")
    }

    var feedMode: FeedCoordinator.Mode {
        return .userLocation
    }
}
