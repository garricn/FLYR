//
//  ProfileCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit

class ProfileCoordinator: Coordinator {
    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController = UINavigationController(rootViewController: LoadingVC())
    
    private let loadingVC = LoadingVC()
    private let fetcher: FlyrFetchable
    private let ownerReference: CKReference
    
    private var navigationController: UINavigationController {
        if let viewController = rootViewController as? UINavigationController {
            return viewController
        } else {
            fatalError("Expects a UINavigationController!")
        }
    }
    
    init(fetcher: FlyrFetchable, ownerReference: CKReference) {
        self.fetcher = fetcher
        self.ownerReference = ownerReference
    }

    func start() {
        fetcher.output.onNext { flyrs in
            let viewModel = ProfileVM(model: flyrs)
            let viewController = FlyrTableVC(viewModel: viewModel)
            let viewControllers = [viewController]
            
            DispatchQueue.main.async {
                self.navigationController.setViewControllers(viewControllers, animated: false)
            }
        }
        
        let predicate = NSPredicate(format: "ownerReference == %@", ownerReference)
        let query = CKQuery(recordType: "Flyr", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        fetcher.fetch(with: operation, and: query)
    }
}
