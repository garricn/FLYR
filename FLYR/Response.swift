//
//  Response.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/17/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

enum Response {
    case successful(Any)
    case notSuccessful(Swift.Error)
    
    enum Error: Swift.Error {
        case unknown
        
        var localizedDescription: String {
            return "Unknown error"
        }
    }
}
