//
//  User.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/5/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit

class User {
    let ownerReference: CKReference

    init(ownerReference: CKReference) {
        self.ownerReference = ownerReference
    }
}
