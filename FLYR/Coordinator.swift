//
//  Coordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

protocol CoordinatorDelegate: class {
    func coordinatorIsReady(coordinator: Coordinator)
}

protocol Coordinator {
    weak var delegate: CoordinatorDelegate? { get set }
    var rootViewController: UIViewController { get }
    func start()
}
