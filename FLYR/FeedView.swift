//
//  FeedView.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import ReactiveKit
import ReactiveUIKit
import Cartography

let screenHeight = UIScreen.mainScreen().nativeBounds.height

class FeedView: BaseView {
    var imageInput: ReactiveKit.Property<UIImage?> {
        return imageView.rImage
    }

    private let imageView = UIImageView()

    override func bind() {
        imageInput.bindTo(imageView.rImage)
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
