//
//  FeedCell.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Cartography

class FeedCell: UITableViewCell {
    let _imageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        imageView?.contentMode = .ScaleAspectFit
        addSubview(_imageView)

        constrain(_imageView) { imageView in
            imageView.edges == imageView.superview!.edges
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
