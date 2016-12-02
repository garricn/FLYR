//
//  AddImageCell.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Cartography

class AddImageCell: UITableViewCell {
    let flyrImageView = UIImageView()

    init() {
        super.init(
            style: .default,
            reuseIdentifier: AddImageCell.description()
        )

        accessoryType = .disclosureIndicator
        addSubview(flyrImageView)

        flyrImageView.contentMode = .scaleAspectFit

        constrain(flyrImageView) { imageView in
            imageView.top == imageView.superview!.top + 8
            imageView.bottom == imageView.superview!.bottom - 8
            imageView.leading == imageView.superview!.leading + 8
            imageView.trailing == imageView.superview!.trailing - 8
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
