//
//  LoadingVC.swift
//  Flow
//
//  Created by Garric G. Nahapetian on 1/28/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit

final class LoadingVC: UIViewController {
    private let loadingView = LoadingView()
    
    override func loadView() {
        view = loadingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.startSpinner()
    }
}
