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

protocol AppCoordinatorDelegate: class {
    func rootViewControllerDidChange(in appCoordinator: AppCoordinator)
}

class AppCoordinator: CoordinatorDelegate {
    
    weak var delegate: AppCoordinatorDelegate?
    
    private(set) var rootViewController: UIViewController!
    
    private var appState: AppState!
    private var childCoordinators: [String: Coordinator] = [:]

    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController {
        guard let appState = AppState(launchOptions: launchOptions) else {
            fatalError("Expects valid app state!")
        }
        
        self.appState = appState
        
        let viewController: UIViewController
        switch appState {
        case .shouldOnboard: viewController = startOnboarding()
        case .shouldStartFeed(let mode): viewController = startFeed(with: mode)
        }
        
        rootViewController = viewController
        return viewController
    }
    
    private func startOnboarding() -> UIViewController {
        let locationManager = LocationManager()
        let coordinator = OnboardingCoordinator(locationManager: locationManager)
        coordinator.delegate = self
        coordinator.start()
        childCoordinators["onboarding"] = coordinator
        return coordinator.rootViewController
    }
    
    private func startFeed(with mode: FeedCoordinator.Mode) -> UIViewController {
        let locationManager = LocationManager()
        let fetcher = resolvedFlyrFetcher()
        let authenticator = Resolved.authenticator()
        let feedCoordinator = FeedCoordinator(
            mode: mode,
            fetcher: fetcher,
            locationManager: locationManager,
            authenticator: authenticator)
        feedCoordinator.delegate = self
        feedCoordinator.start()
        childCoordinators["feed"] = feedCoordinator
        
        let profileCoordinator = ProfileCoordinator()
        profileCoordinator.delegate = self
        childCoordinators["profile"] = profileCoordinator
        
        let feedVC = feedCoordinator.rootViewController
        feedVC.tabBarItem = UITabBarItem(title: "FEED", image: UIImage(), tag: 0)
        feedVC.tabBarItem.accessibilityLabel = "FEED"
        
        let profileVC = profileCoordinator.rootViewController
        profileVC.tabBarItem = UITabBarItem(title: "PROFILE", image: UIImage(), tag: 1)
        profileVC.accessibilityLabel = "PROFILE"
        
        let viewControllers = [feedVC, profileVC]
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(viewControllers, animated: true)
        
        return tabBarController
    }
    
    // MARK: - CoordinatorDelegate
    
    func coordinatorIsReady(coordinator: Coordinator) {
        print("Coordinator is ready called!")
    }
    
    func coordinatorDidFinish(coordinator: Coordinator) {
        let key: String
        
        switch coordinator {
        case let coordinator as OnboardingCoordinator:
            key = "onboarding"
            UserDefaults.standard.set(true, forKey: "hasOnboarded")
            UserDefaults.standard.synchronize()
            rootViewController = startFeed(with: coordinator.selectedMode)
            delegate?.rootViewControllerDidChange(in: self)
        default: fatalError("Incomplete implementation!")
        }

        childCoordinators.removeValue(forKey: key)
    }
}
