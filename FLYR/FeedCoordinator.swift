//
//  FeedCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

class FeedCoordinator: Coordinator {
    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController = UINavigationController(rootViewController: LoadingVC())
    
    private let loadingVC = LoadingVC()
    private let fetcher: FlyrFetchable
    private let locationManager: LocationManageable
    
    init(locationManager: LocationManageable, fetcher: FlyrFetchable) {
        self.locationManager = locationManager
        self.fetcher = fetcher
    }
    
    func start() {
        locationManager.requestLocation { [weak self] response in
            self?.completion(with: response)
        }
    }
    
    private func completion(with response: LocationResponse) {
        switch response {
        case .didUpdateLocations(let locations):
            print(locations)
        case .didFail(let error):
            print(error)
        case .didFailAuthorization(let authorization):
            print(authorization)
        }
    }
}
