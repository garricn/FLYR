//
//  FlyrCell.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/14/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class FlyrCell: UITableViewCell {
    let _imageView = UIImageView()
    static let identifier = "FlyrCell"

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(_imageView)
        
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                _imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                _imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                _imageView.topAnchor.constraint(equalTo: topAnchor),
                _imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
