//
//  FeedCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import MapKit
import CloudKit
import GGNLocationPicker

class FeedCoordinator: Coordinator, FlyrViewModelingDelegate {

    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController = UINavigationController(rootViewController: LoadingVC())
    
    private let appState: FeedAppState
    private let fetcher: FlyrFetchable
    private let locationManager: LocationManageable

    private var navigationController: UINavigationController {
        if let viewController = rootViewController as? UINavigationController {
            return viewController
        } else {
            fatalError("Expects and UINavigationController!")
        }
    }
    
    init(appState: FeedAppState,
         fetcher: FlyrFetchable, locationManager: LocationManageable) {
        self.appState = appState
        self.fetcher = fetcher
        self.locationManager = locationManager
    }
    
    func start() {
        startFeed(with: appState.feedMode)
    }
    
    // MARK: - Feed Start Modes
    
    private func startFeed(with mode: FeedMode) {
        switch mode {
        case .userLocation: startUserLocationMode()
        case .preferred(let annotation): startFeed(with: annotation.location)
        case .losAngeles: startFeed(with: losAngelesAnnotation.location)
        }
        
        fetcher.output.onNext { [weak self] flyrs in
            guard let weakSelf = self else { return }
            
            let viewController = weakSelf.resolvedFeedVC(with: flyrs)
            let viewControllers = [viewController]
            
            DispatchQueue.main.async {
                weakSelf.navigationController.setViewControllers(viewControllers, animated: false)
                weakSelf.delegate?.coordinatorIsReady(coordinator: weakSelf)
            }
        }
    }

    private func startUserLocationMode() {
        locationManager.requestLocation { [weak self] response in
            self?.requestLocationCompletion(with: response)
        }
    }
    
    private func requestLocationCompletion(with response: LocationResponse) {
        switch response {
        case .didUpdateLocations(let locations):
            fetch(with: locations.last!)
            appState.didReceive(userLocation: locations.last!)
        case .didFail(let error):
            assertionFailure("Handle error: \(error)")
        case .didFailAuthorization(let authorization):
            assertionFailure("Handle did fail authorization: \(authorization)")
        }
    }

    private func startFeed(with location: CLLocation) {
        fetch(with: location)
    }

    // MARK: - Private Functions
    
    private func resolvedFeedVC(with flyrs: Flyrs) -> FlyrTableVC {
        let viewModel = FeedVM(model: flyrs)
        viewModel.delegate = self

        let viewController = FlyrTableVC(viewModel: viewModel)
        let selector = #selector(didTapSettingsBarButtonItem)
        let rightBarButtonItem = UIBarButtonItem(title: "⚙️", style: .plain, target: self, action: selector)
        viewController.navigationItem.rightBarButtonItem = rightBarButtonItem
        return viewController
    }
    
    private func currentHandler(action: UIAlertAction) {
        startUserLocationMode()
    }
    
    private func preferredHandler(action: UIAlertAction) {
        let selector = #selector(didTapCancelBarButtonItem)
        let rightBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: selector)
        let locationPickerVC = LocationPickerVC(with: appState.feedMode.annotation)
        locationPickerVC.didPick = annotationCompletion
        locationPickerVC.navigationItem.title = "Preferred Location"
        locationPickerVC.navigationItem.rightBarButtonItem = rightBarButton
        let navigationController = UINavigationController(rootViewController: locationPickerVC)
        rootViewController.present(navigationController, animated: true, completion: nil)
        
    }
    
    private func losAngelesHandler(action: UIAlertAction) {
        appState.didSelect(newFeedMode: .losAngeles)
    }
    
    private func annotationCompletion(annotation: MKAnnotation) {
        appState.didSelect(newFeedMode: .preferred(annotation))
        rootViewController.dismiss(animated: true, completion: nil)
    }
    
    private func fetch(with location: CLLocation) {
        let query = makeQuery(from: location)
        fetcher.fetch(with: query)
    }
    
    private func makeQuery(from location: CLLocation) -> CKQuery {
        let radius: CGFloat = 100000000.0
        let format = "(distanceToLocation:fromLocation:(location, %@) < %f)"
        let predicate = NSPredicate(
            format: format,
            location,
            radius
        )
        return CKQuery(recordType: "Flyr", predicate: predicate)
    }
    
    // MARK: - Private Selectors
    
    @objc private func didTapSettingsBarButtonItem(sender: UIBarButtonItem) {
        let description: String
        let mode = appState.feedMode
        
        switch mode {
        case .preferred(let annotation): description = "\(mode.displayName): \(annotation.displayName)"
        default: description = mode.displayName
        }
        
        let title = "Current Feed Mode is:\n\(description)"
        let message = "Feel free to select a different mode:"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let current = UIAlertAction(title: "Current Location", style: .default, handler: currentHandler)
        let preferred = UIAlertAction(title: "Preferred Location", style: .default, handler: preferredHandler)
        let losAngeles = UIAlertAction(title: "Los Angeles", style: .default, handler: losAngelesHandler)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let actions: [UIAlertAction]
        switch appState.feedMode {
        case .userLocation: actions = [preferred, losAngeles]
        case .preferred: actions = [current, preferred, losAngeles]
        case .losAngeles: actions = [current, preferred]
        }
        
        actions.forEach { action in
            alertController.addAction(action)
        }
        
        alertController.addAction(cancel)
        
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func didTapCancelBarButtonItem(sender: UIBarButtonItem) {
        rootViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - FlyrViewModelingDelegate
    
    func didPullToRefresh(in viewModel: FlyrViewModeling) {
        fetcher.refreshOutput.onNext { flyrs in
            viewModel.didReceive(flyrs)
        }
        
        locationManager.requestLocation { [weak self] response in
            self?.refreshLocationCompletion(response: response)
        }
    }
    
    private func refreshLocationCompletion(response: LocationResponse) {
        switch response {
        case .didUpdateLocations(let locations):
            let query = self.makeQuery(from: locations.last!)
            fetcher.fetch(with: query)
        default: break
        }
    }
}
