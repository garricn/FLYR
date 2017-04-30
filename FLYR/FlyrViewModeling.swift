//
//  FlyrViewModeling.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/8/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol FlyrConfigurable: class {
    func configure(with flyrs: [Flyr])
    weak var delegate: FlyrViewModelingDelegate? { get set }
}

protocol FlyrViewModelingDelegate: class {
    func refresh()
    func didPullToRefresh(in viewModel: FlyrConfigurable)
    func didLongPress(on flyr: Flyr)
}

protocol FlyrViewModeling: class, TableViewDataSource, FlyrInteracting {
    var onModelUpdated: (() -> Void)? { get set }
    func refresh()
}

protocol FlyrInteracting {
    func didPullToRefresh()
    func didLongPress(sender: UILongPressGestureRecognizer, in tableView: UITableView)
}

protocol TableViewDataSource {
    func numberOfSections() -> Int
    func numbersOfRows(inSection section: Int) -> Int
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: IndexPath) -> CGFloat
}
