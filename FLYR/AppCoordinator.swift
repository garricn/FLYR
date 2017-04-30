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

private typealias ProtocolComposite = UITabBarControllerDelegate
    & Coordinator
    & LaunchNavigationControllerDelegate
    & CoordinatorDelegate

class AppCoordinator: NSObject, ProtocolComposite {
    
    let rootViewController: UIViewController

    weak var delegate: CoordinatorDelegate?
    
    private let appState: AppState
    private let authenticator: Authenticating

    private var childCoordinators: [CoordinatorKey: Coordinator] = [:]
    
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
        self.rootViewController = UITabBarController()
        
        super.init()
        
        let viewController = UIViewController()
        let navigationController = LaunchNavigationController(rootViewController: viewController)
        navigationController.launchDelegate = self
        
        tabBarController.setViewControllers([navigationController], animated: true)
        tabBarController.delegate = self
        
        DispatchQueue.global().async {
            self.authenticator.authenticate { [weak self] response in
                self?.authenticationCompletion(response: response)
            }
        }
    }

    // MARK: - CoordinatorDelegate
    
    func coordinatorDidFinish(coordinator: Coordinator) {
        if let coordinator = coordinator as? OnboardingCoordinator {
            let selectedFeedMode = coordinator.selectedFeedMode
            
            startFeed(with: selectedFeedMode)

            coordinator.rootViewController.dismiss(animated: true) {
                self.childCoordinators.removeValue(forKey: .onboarding)
                self.appState.onboardingCompleted(with: selectedFeedMode)
            }
        }
    }
    
    // MARK: - LaunchNavigationControllerDelegate
    
    func viewDidAppear(in launchNavigationController: LaunchNavigationController) {
        if appState.isExistingUser {
            startFeed(with: appState.feedMode)
        } else {
            let locationManager = LocationManager()
            let coordinator = OnboardingCoordinator(locationManager: locationManager)
            coordinator.delegate = self
            launchNavigationController.present(coordinator.rootViewController, animated: true) {
                self.childCoordinators[.onboarding] = coordinator
            }
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard viewController.tabBarItem.tag == 1 else {
            return true
        }
        
        let postCoordinator = PostCoordinator(ownerReference: appState.ownerReference)
        rootViewController.present(postCoordinator.rootViewController, animated: true) {
            self.childCoordinators[.post] = postCoordinator
        }

        return false
    }
    
    // MARK: - Private Functions
    
    private func startFeed(with mode: FeedMode) {
        
        // Feed
        let fetcher = Resolved.flyrFetcher
        let manager = LocationManager()
        let feedCoordinator = FeedCoordinator(appState: appState, fetcher: fetcher, locationManager: manager)
        childCoordinators[.feed] = feedCoordinator
        
        let feedVC = feedCoordinator.rootViewController
        feedVC.tabBarItem = UITabBarItem(title: "FEED", image: nil, tag: 0)
        feedVC.tabBarItem.accessibilityLabel = "FEED"
        
        // Dummy PostVC
        let postVC = UIViewController()
        postVC.tabBarItem = UITabBarItem(title: "POST", image: nil, tag: 1)
        postVC.accessibilityLabel = "POST"

        // Profile
        let profileCoordinator = ProfileCoordinator(appState: appState, fetcher: Resolved.flyrFetcher)        
        childCoordinators[.profile] = profileCoordinator
        
        let profileVC = profileCoordinator.rootViewController
        profileVC.tabBarItem = UITabBarItem(title: "PROFILE", image: nil, tag: 2)
        profileVC.accessibilityLabel = "PROFILE"
        
        let viewControllers = [feedVC, postVC, profileVC]
        tabBarController.setViewControllers(viewControllers, animated: true)
    }
    
    private func authenticationCompletion(response: Authenticator.AuthResponse) {
        switch response {
        case .authenticated(let reference): appState.authenticationCompleted(with: reference)
        case .notAuthenticated(let error): fatalError("Error authenticating: \(error)")
        }
    }
    
    // MARK - Nested Types
    
    enum CoordinatorKey: String {
        case feed = "feed"
        case profile = "profile"
        case post = "post"
        case onboarding = "onboarding"
    }
}
