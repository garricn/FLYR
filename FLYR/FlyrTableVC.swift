
//  FlyrTableVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/8/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

final class FlyrTableVC: UITableViewController {

    private let viewModel: FlyrViewModeling

    init(viewModel: FlyrViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemeneted!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.register(FlyrCell.self, forCellReuseIdentifier: FlyrCell.identifier)
        
        viewModel.onModelUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
        }
        
        viewModel.refresh()
    }
    
    // MARK: - Private Selectors
    
    @objc private func didPullToRefresh(sender: UIRefreshControl) {
        viewModel.didPullToRefresh()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersOfRows(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellForRow(at: indexPath, in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath)
    }
}
