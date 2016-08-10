//
//  FeedView.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond
import Cartography

class FeedView: BaseView {
    var imageInput: Observable<UIImage?> {
        return imageView.bnd_image
    }

    private let imageView = UIImageView()

    override func bind() {
        imageInput.bindTo(imageView.bnd_image)
    }

    override func setup() {
        addSubview(imageView)
    }

    override func style() {
        imageView.contentMode = .ScaleAspectFit
    }

    override func layout() {
        constrain(imageView) { imageView in
            imageView.top == imageView.superview!.top + 8
            imageView.leading == imageView.superview!.leading + 8
            imageView.trailing == imageView.superview!.trailing - 8
            imageView.bottom == imageView.superview!.bottom - 8
        }
    }
}
