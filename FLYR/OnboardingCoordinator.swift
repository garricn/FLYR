//
//  OnboardingCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit
import GGNLocationPicker

class OnboardingCoordinator: Coordinator, OnboardingDelegate {
    let rootViewController: UIViewController = UINavigationController(rootViewController: OnboardingVC())
    
    weak var delegate: CoordinatorDelegate?
    
    private(set) var selectedFeedMode: FeedCoordinator.Mode = .losAngeles
    
    private enum State {
        case stepOne, stepTwo, stepThree, stepFour
        
        var labelText: String {
            switch self {
            case .stepOne:
                return "Welcome to FLYR,\n"
                + "the app that shows you flyers\n"
                + "for events happening near and now.\n"
                + "Tap \"Get Started\" to begin."
            case .stepTwo:
                return "FLYR needs your permission\n"
                + "to show you flyers based on your location.\n"
                + "Tap \"Allow When Use In Authorization\" to use your location.\n"
            case .stepThree:
                return "Instead of using your location,\n"
                + "FLYR can use your preferred location\n"
                + "to show you the most relevant flyers.\n"
            case .stepFour:
                return "Have fun using FLYR!"
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .stepOne: return "Get Started"
            case .stepTwo: return "Allow When In Use Authorization"
            case .stepThree: return "Set Preferred Location Now"
            case .stepFour: return "Let's go!"
            }
        }
    }
    
    private let locationManager: LocationManageable
    
    private var navigationController: UINavigationController {
        guard let viewController = rootViewController as? UINavigationController else {
            fatalError("Expects a UINavigationController!")
        }
        
        return viewController
    }
    
    private var state: OnboardingCoordinator.State = .stepOne {
        didSet {
            let onboardingVC = OnboardingVC()
            onboardingVC.delegate = self
            onboardingVC.setLabelText(state.labelText)
            onboardingVC.setButtonPrimaryTitle(state.buttonTitle)
            onboardingVC.isSecondaryButtonHidden = state != .stepTwo && state != .stepThree
            navigationController.pushViewController(onboardingVC, animated: true)
        }
    }
    
    init(locationManager: LocationManageable) {
        self.locationManager = locationManager
        self.navigationController.isNavigationBarHidden = true
    }
    
    func start() {
        if let onboardingVC = navigationController.topViewController as? OnboardingVC {
            onboardingVC.delegate = self
            onboardingVC.setLabelText(state.labelText)
            onboardingVC.setButtonPrimaryTitle(state.buttonTitle)
            onboardingVC.isSecondaryButtonHidden = true
        }
    }
    
    func didTapPrimaryButton() {
        switch state {
        case .stepOne: state = stateFrom(state: .stepOne)
        case .stepTwo: requestWhenInUseAuthrization()
        case .stepThree: presentPreferredLocationVC()
        case .stepFour: finishOnboarding()
        }
    }
    
    func didTapSecondaryButton() {
        switch state {
        case .stepOne:
            break
        case .stepTwo:
            state = .stepThree
        case .stepThree:
            state = .stepFour
            selectedFeedMode = .losAngeles
        case .stepFour:
            break
        }
    }
    
    private func stateFrom(state: State) -> State {
        switch state {
        case .stepOne:
            if locationManager.enabledAndAuthorized {
                return .stepFour
            } else if locationManager.deniedOrRestricted {
                return .stepThree
            } else {
                return  .stepTwo
            }
        case .stepTwo: break
        case .stepThree: break
        case .stepFour: break
        }
        return .stepFour
    }
    
    private func requestWhenInUseAuthrization() {
        locationManager.requestWhenInUseAuthorization { [weak self] response in
            self?.completion(with: response)
        }
    }
    
    private func completion(with response: AuthorizationResponse) {
        switch response {
        case .authorizationGranted:
            state = .stepFour
            selectedFeedMode = .userLocation(nil)
        case .authorizationDenied, .authorizationRestricted, .servicesNotEnabled:
            state = .stepThree
        }
    }
    
    private func presentPreferredLocationVC() {
        let locationPicker = LocationPickerVC()
        locationPicker.didPick = { [weak self] annotaion in
            self?.rootViewController.dismiss(animated: true) {
                self?.selectedFeedMode = .preferred(annotaion)
                self?.state = .stepFour
            }
        }
        let navigationController = UINavigationController(rootViewController: locationPicker)
        rootViewController.present(navigationController, animated: true)
    }
    
    private func finishOnboarding() {
        delegate?.coordinatorDidFinish(coordinator: self)
    }
}
