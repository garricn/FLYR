//
//  ProfileCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

class ProfileCoordinator: Coordinator {
    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController = UINavigationController(rootViewController: LoadingVC())
    
    private let loadingVC = LoadingVC()
    
    func start() {
    }
}
