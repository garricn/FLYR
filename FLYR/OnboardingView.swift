//
//  OnboardingView.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/29/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

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
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
            ]
        )
        
        primarybutton.translatesAutoresizingMaskIntoConstraints = false
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                primarybutton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                primarybutton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
                secondaryButton.topAnchor.constraint(equalTo: primarybutton.bottomAnchor, constant: 20),
                secondaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                secondaryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                secondaryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80),
            ]
        )
    }
}
