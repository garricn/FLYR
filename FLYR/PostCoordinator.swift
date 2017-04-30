//
//  PostCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 4/3/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit

final class PostCoordinator: Coordinator {
    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController //= UINavigationController(rootViewController: UIViewController())
    
    private var ownerReference: CKReference?
    
    private var navigationController: UINavigationController {
        if let viewController = rootViewController as? UINavigationController {
            return viewController
        } else {
            fatalError("Expects a UINavigationController!")
        }
    }
    
    init(ownerReference: CKReference?) {
        self.ownerReference = ownerReference
        
        let saver = Resolved.recordSaver
        let viewModel = AddFlyrVM(recordSaver: saver)
        let postVC = AddFlyrVC(viewModel: viewModel, ownerReference: ownerReference)
        rootViewController = UINavigationController(rootViewController: postVC)
    }
}
