//
//  Flyr.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

protocol FlyrProtocol {
    var image: UIImage { get }
}

struct Flyr: FlyrProtocol {
    let image: UIImage
}

protocol Record {}