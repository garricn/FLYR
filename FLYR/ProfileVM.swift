//
//  ProfileVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/5/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import GGNObservable

class ProfileVM: FlyrViewModeling {
    let model: Flyrs

    init(model: Flyrs) {
        self.model = model
    }
}
