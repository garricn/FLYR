//
//  AddImageCell.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class AddImageCell: UITableViewCell {
    let flyrImageView = UIImageView()
    static let identifier: String = "AddImageCell"

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator
        addSubview(flyrImageView)

        flyrImageView.contentMode = .scaleAspectFit
        flyrImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                flyrImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                flyrImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                flyrImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                flyrImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
