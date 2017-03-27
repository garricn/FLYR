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


class AppCoordinator: CoordinatorDelegate {
    private var appState: AppState!
    private var rootViewController: UIViewController!
    private var childCoordinators: [String: Coordinator] = [:]

    func rootViewController(from launchOptions: LaunchOptions) -> UIViewController {
        guard let appState = AppState(launchOptions: launchOptions) else {
            fatalError("Expects valid app state!")
        }
        
        self.appState = appState
        
        let viewController: UIViewController
        switch appState {
        case .shouldOnboard: viewController = startOnboarding()
        case .loggedOut: viewController = startFeed()
        }
        
        rootViewController = viewController
        return viewController
    }
    
    private func startOnboarding() -> UIViewController {
        let onboardingCoordinator = OnboardingCoordinator(locationManager: LocationManager())
        onboardingCoordinator.delegate = self
        onboardingCoordinator.start()
        childCoordinators["onboarding"] = onboardingCoordinator
        return onboardingCoordinator.rootViewController
    }
    
    private func startFeed() -> UIViewController {
        let locationManager = LocationManager()
        let fetcher = resolvedFlyrFetcher()
        let feedCoordinator = FeedCoordinator(locationManager: locationManager, fetcher: fetcher)
        feedCoordinator.delegate = self
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
    }
    
    // MARK: - Private Functions

    private func locationButtonTapped() {
        let locationPicker = LocationPickerVC(with: preferredLocation())
        locationPicker.navigationItem.title = "Set Search Area"
        locationPicker.navigationItem.rightBarButtonItem = makeCancelButton(for: locationPicker)
        locationPicker.didPick = {
            self.save(preferredLocation: $0)
            locationPicker.presentingViewController?.dismiss(animated: true, completion: nil)
        }

        let vc = UINavigationController(rootViewController: locationPicker)
        rootViewController.present(vc, animated: true, completion: nil)
    }

    private func addButtonTapped() {
//        authenticator.authenticate { ownerReference, error in
//            if let reference = ownerReference {
//                let rootVC = resolvedAddFlyrVC(with: reference)
//                let vc = UINavigationController(rootViewController: rootVC)
//                self.viewControllerOutput.emit(vc)
//            } else if let error = error {
//                let alert = makeAlert(from: error)
//                self.alertOutput.emit(alert)
//            }
//        }
    }

    private func cancelButtonTapped() {
        rootViewController.dismiss(animated: true, completion: nil)
    }

    private func didFinishAddingFlyr() {
        rootViewController.dismiss(animated: true, completion: nil)
    }

//    private func ownerReference() -> CKReference? {
//        return authenticator.ownerReference()
//    }

    private func preferredLocation() -> MKAnnotation? {
        guard
            let dictionary = UserDefaults.standard.dictionary(forKey: "PreferredLocation"),
            let title = dictionary["title"] as? String,
            let subtitle = dictionary["subtitle"] as? String,
            let coordinate = dictionary["coordinate"] as? [String: Any],
            let latitude = coordinate["latitude"] as? Double,
            let longitude = coordinate["longitude"] as? Double
            else { return nil }

        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coord
        return annotation
    }

    private func save(preferredLocation annotation: MKAnnotation) {
        let preferredLocation: [String: Any] = [
            "title": (annotation.title!)!,
            "subtitle": (annotation.subtitle!)!,
            "coordinate": [
                "latitude": annotation.coordinate.latitude,
                "longitude": annotation.coordinate.longitude
            ]
        ]

        UserDefaults.standard.set(preferredLocation, forKey: "PreferredLocation")
        UserDefaults.standard.synchronize()
    }
}


private func pointAnnotation(from annotation: MKAnnotation) -> MKPointAnnotation {
    let pointAnnotation = MKPointAnnotation()
    pointAnnotation.coordinate = annotation.coordinate
    pointAnnotation.title = annotation.title!
    pointAnnotation.subtitle = annotation.subtitle!
    return pointAnnotation
}
