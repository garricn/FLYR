//
//  OnboardingView.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/29/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

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
