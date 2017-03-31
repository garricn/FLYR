//
//  AppCoordinator.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit
import GGNObservable
import GGNLocationPicker
import MapKit
import CoreLocation

class AppCoordinator: NSObject, UINavigationControllerDelegate, CoordinatorDelegate {
    
    var rootViewController: UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .red
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.delegate = self
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([navigationController], animated: true)
        return tabBarController
    }

    private let appState: AppState
    private let authenticator: Authenticating

    private var childCoordinators: [String: Coordinator] = [:]
    private var tabBarController: UITabBarController {
        if let viewController = rootViewController as? UITabBarController {
            return viewController
        } else {
            fatalError("Expects a UITabBarController!")
        }
    }

    init(appState: AppState, authenticator: Authenticating) {
        self.appState = appState
        self.authenticator = authenticator
    }
    
    func start() {
        DispatchQueue.global().async {
            self.authenticator.authenticate()
        }
    }
    
    
    // MARK: - CoordinatorDelegate
    
    func coordinatorIsReady(coordinator: Coordinator) {}
    
    func coordinatorDidFinish(coordinator: Coordinator) {
        if let coordinator = coordinator as? OnboardingCoordinator {
            startFeed(with: coordinator.selectedMode)

            coordinator.rootViewController.dismiss(animated: true) {
                self.childCoordinators.removeValue(forKey: "onboarding")
            }
        }
    }
    
    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if appState.isExistingUser {
            startFeed(with: appState.feedMode)
        } else {
            let locationManager = LocationManager()
            let coordinator = OnboardingCoordinator(locationManager: locationManager)
            coordinator.delegate = self
            coordinator.start()
            navigationController.present(coordinator.rootViewController, animated: true) {
                self.childCoordinators["onboarding"] = coordinator
            }
        }
    }
    
    // MARK: - Private Functions
    
    // TODO: - Inject Coordinators with AppState (full/partial?)
    private func startFeed(with mode: FeedCoordinator.Mode) {
        let fetcher0 = Resolved.flyrFetcher
        let manager = LocationManager()
        let feedCoordinator = FeedCoordinator(mode: mode, fetcher: fetcher0, locationManager: manager)
        feedCoordinator.delegate = self
        feedCoordinator.start()
        childCoordinators["feed"] = feedCoordinator
        
        let feedVC = feedCoordinator.rootViewController
        feedVC.tabBarItem = UITabBarItem(title: "FEED", image: UIImage(), tag: 0)
        feedVC.tabBarItem.accessibilityLabel = "FEED"
        
        let fetcher1 = Resolved.flyrFetcher
        let reference = authenticator.ownerReference()
        let profileCoordinator = ProfileCoordinator(fetcher: fetcher1, ownerReference: reference)
        profileCoordinator.delegate = self
        childCoordinators["profile"] = profileCoordinator
        
        let profileVC = profileCoordinator.rootViewController
        profileVC.tabBarItem = UITabBarItem(title: "PROFILE", image: UIImage(), tag: 1)
        profileVC.accessibilityLabel = "PROFILE"
        
        let viewControllers = [feedVC, profileVC]
        tabBarController.setViewControllers(viewControllers, animated: true)
    }
}
