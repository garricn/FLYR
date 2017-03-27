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
    case loggedOut
    
    private static let userDefaults = UserDefaults.standard
    
    init?(launchOptions: LaunchOptions) {
        if launchOptions == nil {
            let shouldOnboard = !AppState.userDefaults.bool(forKey: "hasOnboarded")
            
            if shouldOnboard {
                self = .shouldOnboard
            } else {
                self = .loggedOut
            }
        } else {
            fatalError("Handle launch options!")
        }
    }
}
