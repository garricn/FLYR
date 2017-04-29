//
//  LaunchNavigationController.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 4/3/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

protocol LaunchNavigationControllerDelegate: class {
    func viewDidAppear(in launchNavigationController: LaunchNavigationController)
}

final class LaunchNavigationController: UINavigationController {
    
    weak var launchDelegate: LaunchNavigationControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        launchDelegate?.viewDidAppear(in: self)
    }
}
