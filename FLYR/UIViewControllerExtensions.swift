//
//  UIViewControllerExtensions.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/9/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentedViewControllerDidCancel() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
