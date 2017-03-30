//
//  OnboardingVC.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/29/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

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
