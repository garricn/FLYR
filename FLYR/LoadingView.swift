//
//  LoadingView.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/7/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    init() {
        super.init(frame: CGRect.zero)

        addSubview(spinner)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        spinner.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        spinner.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func start() {
        spinner.startAnimating()
    }

    func stop() {
        spinner.stopAnimating()
    }
}
