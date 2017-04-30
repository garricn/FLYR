//
//  PostCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 4/3/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit

final class PostCoordinator: Coordinator, PostViewModelDelegate {
    let rootViewController: UIViewController

    weak var delegate: CoordinatorDelegate?

    private var ownerReference: CKReference?
    private let appState: PostAppState
    private let viewModel: PostViewModel
    
    private var navigationController: UINavigationController {
        if let viewController = rootViewController as? UINavigationController {
            return viewController
        } else {
            fatalError("Expects a UINavigationController!")
        }
    }
    
    init(appState: PostAppState) {
        self.appState = appState
        
        let saver = Resolved.recordSaver
        let viewModel = AddFlyrVM(appState: appState, recordSaver: saver)
        let postVC = AddFlyrVC(viewModel: viewModel)
        rootViewController = UINavigationController(rootViewController: postVC)
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }
    
    func didFinishAddingFlyr(in viewModel: AddFlyrViewModeling) {
        DispatchQueue.main.async {
            self.delegate?.coordinatorDidFinish(coordinator: self)
        }
    }
}
