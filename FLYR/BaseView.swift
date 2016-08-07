//
//  BaseView.swift
//  Farmers
//
//  Created by John Basile on 4/14/16.
//  Copyright © 2016 Farmers Insurance Group. All rights reserved.
//

import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        bind()
        style()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup() {}
    func bind() {}
    func style() {}
    func layout() {}
}