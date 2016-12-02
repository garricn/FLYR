//
//  Globals.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/15/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

// MARK: - Properties
let screenBounds = UIScreen.main.bounds
let screenWidth = screenBounds.width
let screenHeight = screenBounds.height

// MARK: - Functions
func rowHeight(from image: UIImage) -> CGFloat {
    let ratio = image.size.height / image.size.width
    return UIScreen.main.bounds.width * ratio
}
