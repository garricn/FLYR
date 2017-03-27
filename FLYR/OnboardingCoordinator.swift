//
//  OnboardingCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

class OnboardingCoordinator: Coordinator, OnboardingDelegate {
    let rootViewController: UIViewController = UINavigationController(rootViewController: OnboardingVC())
    
    weak var delegate: CoordinatorDelegate?
    
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
        case .stepOne: state = .stepTwo
        case .stepTwo: requestWhenInUseAuthrization()
        case .stepThree: break
        case .stepFour: break
        }
    }
    
    func didTapSecondaryButton() {
        switch state {
        case .stepOne: break
        case .stepTwo: state = .stepThree
        case .stepThree: state = .stepFour
        case .stepFour: break
        }
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
        case .authorizationDenied, .authorizationRestricted, .servicesNotEnabled:
            state = .stepThree
        }
    }
}

protocol OnboardingDelegate: class {
    func didTapPrimaryButton()
    func didTapSecondaryButton()
}

class OnboardingVC: UIViewController {
    weak var delegate: OnboardingDelegate?
    
    var isSecondaryButtonHidden: Bool {
        get {
            return onboardingView.secondaryButton.isHidden
        }
        set {
            onboardingView.secondaryButton.isHidden = newValue
        }
    }
    
    private let onboardingView = OnboardingView()
    
    override func loadView() {
        view = onboardingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        onboardingView.primarybutton.addTarget(
            self,
            action: #selector(didTapPrimaryButton),
            for: .touchUpInside)
        onboardingView.secondaryButton.addTarget(
            self,
            action: #selector(didTapSecondaryButton),
            for: .touchUpInside)
        onboardingView.secondaryButton.setTitle("Skip", for: .normal)
    }
    
    @objc private func didTapPrimaryButton(sender: UIButton) {
        delegate?.didTapPrimaryButton()
    }

    @objc private func didTapSecondaryButton(sender: UIButton) {
        delegate?.didTapSecondaryButton()
    }
    
    func setLabelText(_ labelText: String) {
        onboardingView.labelText = labelText
    }
    
    func setButtonPrimaryTitle(_ buttonTitle: String) {
        onboardingView.primaryButtonTitle = buttonTitle
    }
}


import Cartography

class OnboardingView: BaseView {
    let primarybutton = UIButton()
    let secondaryButton = UIButton()
    
    var labelText: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var primaryButtonTitle: String? {
        get {
            return primarybutton.currentTitle
        }
        set {
            primarybutton.setTitle(newValue, for: .normal)
        }
    }
    
    private let label = UILabel()
    
    override func setup() {
        addSubview(label)
        addSubview(primarybutton)
        addSubview(secondaryButton)
    }
    
    override func style() {
        backgroundColor = .white

        label.numberOfLines = 0
        label.textAlignment = .center
        
        primarybutton.setTitleColor(.blue, for: .normal)
        
        secondaryButton.setTitleColor(.gray, for: .normal)
    }
    
    override func layout() {
        constrain(label) { label in
            label.leading == label.superview!.leading + 10
            label.trailing == label.superview!.trailing - 10
            label.centerY == label.superview!.centerY
        }
        
        constrain(primarybutton, secondaryButton) { primaryButton, secondaryButton in
            primaryButton.leading == primaryButton.superview!.leading + 10
            primaryButton.trailing == primaryButton.superview!.trailing - 10

            secondaryButton.top == primaryButton.bottom + 20
            secondaryButton.leading == secondaryButton.superview!.leading + 10
            secondaryButton.trailing == secondaryButton.superview!.trailing - 10
            secondaryButton.bottom == secondaryButton.superview!.bottom - 80
        }
    }
}
