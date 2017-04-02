//
//  ProfileCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit
import GGNLocationPicker
import MapKit

class ProfileCoordinator: Coordinator {
    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController = UINavigationController(rootViewController: LoadingVC())
    
    private let loadingVC = LoadingVC()
    private let fetcher: FlyrFetchable
    private let appState: ProfileAppState
    
    private var navigationController: UINavigationController {
        if let viewController = rootViewController as? UINavigationController {
            return viewController
        } else {
            fatalError("Expects a UINavigationController!")
        }
    }
    
    init(appState: ProfileAppState, fetcher: FlyrFetchable) {
        self.appState = appState
        self.fetcher = fetcher
    }

    func start() {
        guard let reference = appState.ownerReference else {
            return
        }

        fetcher.output.onNext { [weak self] flyrs in
            guard let weakSelf = self else { return }
            
            let viewController = weakSelf.resolvedFlyrTableVC(with: flyrs)
            let viewControllers = [viewController]
            
            DispatchQueue.main.async {
                weakSelf.navigationController.setViewControllers(viewControllers, animated: true)
                weakSelf.delegate?.coordinatorIsReady(coordinator: weakSelf)
            }
        }
        
        let predicate = NSPredicate(format: "ownerReference == %@", reference)
        let query = CKQuery(recordType: "Flyr", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        fetcher.fetch(with: operation, and: query)
    }
    
    private func resolvedFlyrTableVC(with flyrs: Flyrs) -> UIViewController {
        let viewModel = ProfileVM(model: flyrs)
        let viewController = FlyrTableVC(viewModel: viewModel)
        return viewController
    }
}
