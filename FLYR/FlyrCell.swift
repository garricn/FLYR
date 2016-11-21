//
//  FlyrCell.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Cartography

class FlyrCell: UITableViewCell {
    let _imageView = UIImageView()
    static let identifier = FlyrCell.description()

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
