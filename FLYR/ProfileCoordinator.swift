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

class ProfileCoordinator: Coordinator, FlyrViewModelingDelegate {
    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController
    
    private let fetcher: FlyrFetchable
    private let appState: ProfileAppState
    private let viewModel: FlyrConfigurable
    
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
        
        let viewModel = ProfileVM(model: [])
        let viewController = FlyrTableVC(viewModel: viewModel)
        rootViewController = UINavigationController(rootViewController: viewController)
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }

    func start() {}
    
    func refresh() {
        guard let reference = appState.ownerReference else {
            return
        }
        
        fetcher.output.onNext { [weak self] flyrs in
            self?.viewModel.configure(with: flyrs)
        }
        
        fetcher.errorOutput.onNext { error in
            print(error!)
        }
        
        let predicate = NSPredicate(format: "ownerReference == %@", reference)
        let query = CKQuery(recordType: "Flyr", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        fetcher.fetch(with: operation, and: query)
    }
    
    func didPullToRefresh(in viewModel: FlyrConfigurable) {
        refresh()
    }
}
