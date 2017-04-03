//
//  FlyrViewModeling.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/8/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import GGNObservable

protocol FlyrViewModelingDelegate: class {
    func didPullToRefresh(in viewModel: FlyrViewModeling)
}

protocol FlyrViewModeling: TableViewDataSource, FlyrInteracting {
    var output: Observable<Flyrs> { get }
    weak var delegate: FlyrViewModelingDelegate? { get set }
    func didReceive(_ flyrs: Flyrs)
}

protocol FlyrInteracting {
    func didPullToRefresh()
}

protocol TableViewDataSource {
    func numberOfSections() -> Int
    func numbersOfRows(inSection section: Int) -> Int
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: IndexPath) -> CGFloat
}
