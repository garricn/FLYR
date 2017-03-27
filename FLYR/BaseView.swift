//
//  BaseView.swift
//  Flow
//
//  Created by Garric G. Nahapetian on 1/28/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {}
    func style() {}
    func layout() {}
}
