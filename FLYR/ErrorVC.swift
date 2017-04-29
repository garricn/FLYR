//
//  ErrorVC.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 4/4/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

final class ErrorVC: UIViewController {
    private let errorView = ErrorView()
    
    override func loadView() {
        view = errorView
    }
    
    init(error: Error?) {
        errorView.configure(with: error)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ErrorView: BaseView {
    
    private let errorLabel = UILabel()
    
    override func setup() {
        addSubview(errorLabel)
    }
    
    override func style() {
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.textColor = .gray
    }
    
    override func layout() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(with error: Error?) {
        errorLabel.text = error?.localizedDescription ?? "Unknown Error"
    }
}
