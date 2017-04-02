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

protocol LaunchNavigationControllerDelegate: class {
    func viewDidAppear(in launchNavigationController: LaunchNavigationController)
}

final class LaunchNavigationController: UINavigationController {
    
    weak var launchDelegate: LaunchNavigationControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        launchDelegate?.viewDidAppear(in: self)
    }
}

protocol AppCoordinatorProtocolComposite:
UITabBarControllerDelegate,
LaunchNavigationControllerDelegate,
CoordinatorDelegate {}

class AppCoordinator: NSObject, AppCoordinatorProtocolComposite {
    
    var rootViewController: UIViewController!

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
        let viewController = UIViewController()
        let navigationController = LaunchNavigationController(rootViewController: viewController)
        navigationController.launchDelegate = self

        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([navigationController], animated: true)
        tabBarController.delegate = self
        rootViewController = tabBarController

        DispatchQueue.global().async {
            self.authenticator.authenticate { [weak self] response in
                self?.authenticationCompletion(response: response)
            }
        }
    }
    
    // MARK: - CoordinatorDelegate
    
    func coordinatorIsReady(coordinator: Coordinator) {
        print("Coordinator is ready: \(coordinator)")
    }
    
    func coordinatorDidFinish(coordinator: Coordinator) {
        if let coordinator = coordinator as? OnboardingCoordinator {
            let selectedFeedMode = coordinator.selectedFeedMode
            
            startFeed(with: selectedFeedMode)

            coordinator.rootViewController.dismiss(animated: true) {
                self.childCoordinators.removeValue(forKey: "onboarding")
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
            coordinator.start()
            launchNavigationController.present(coordinator.rootViewController, animated: true) {
                self.childCoordinators["onboarding"] = coordinator
            }
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard viewController.tabBarItem.tag == 1 else {
            return true
        }
        
        let postCoordinator = PostCoordinator(ownerReference: appState.ownerReference)
        postCoordinator.delegate = self
        postCoordinator.start()

        rootViewController.present(postCoordinator.rootViewController, animated: true) {
            self.childCoordinators["post"] = postCoordinator
        }

        return false
    }
    
    // MARK: - Private Functions
    
    private func startFeed(with mode: FeedCoordinator.Mode) {
        
        // Feed
        let fetcher = Resolved.flyrFetcher
        let manager = LocationManager()
        let feedCoordinator = FeedCoordinator(appState: appState, fetcher: fetcher, locationManager: manager)
        feedCoordinator.delegate = self
        feedCoordinator.start()
        childCoordinators["feed"] = feedCoordinator
        
        let feedVC = feedCoordinator.rootViewController
        feedVC.tabBarItem = UITabBarItem(title: "FEED", image: nil, tag: 0)
        feedVC.tabBarItem.accessibilityLabel = "FEED"
        
        // Dummy PostVC
        let postVC = UIViewController()
        postVC.tabBarItem = UITabBarItem(title: "POST", image: nil, tag: 1)
        postVC.accessibilityLabel = "POST"

        // Profile
        let profileCoordinator = ProfileCoordinator(appState: appState, fetcher: Resolved.flyrFetcher)
        profileCoordinator.delegate = self
        profileCoordinator.start()
        childCoordinators["profile"] = profileCoordinator
        
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
}

final class PostCoordinator: Coordinator {
    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController = UINavigationController(rootViewController: UIViewController())
    
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
        navigationController.setViewControllers([postVC], animated: false)
    }
    
    func start() {}
}
