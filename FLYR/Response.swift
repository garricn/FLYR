//
//  Response.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/17/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

enum Response {
    case successful(Any)
    case notSuccessful(Error)
}
