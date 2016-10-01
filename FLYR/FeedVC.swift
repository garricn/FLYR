//
//  FeedVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond

class FeedVC: UITableViewController {
    let viewModel: FeedVM

    init(feedVM: FeedVM) {
        self.viewModel = feedVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = FeedVM(
            flyrFetcher: FlyrFetcher(database: resolvedPublicDatabase()),
            locationManager: LocationManager()
        )
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObservers()
        resetUI(forState: .Loading)
        viewModel.refreshFeed()
    }

    func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: #selector(addButtonTapped)
        )

        tableView.registerClass(
            FeedCell.self,
            forCellReuseIdentifier: FeedCell.description()
        )

        tableView.showsVerticalScrollIndicator = false

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(refreshControlValueChanged),
            forControlEvents: .ValueChanged
        )
    }

    func setupObservers() {
        viewModel
            .alertOutput
            .deliverOn(Queue.Main)
            .observe { alertController in
                self.presentViewController(
                    alertController,
                    animated: true,
                    completion: { self.resetUI(forState: .ErrorLoading) }
                )
            }.disposeIn(bnd_bag)

        viewModel
            .doneLoadingOutput
            .deliverOn(Queue.Main)
            .observe {
                self.resetUI(forState: .DoneLoading)
            }.disposeIn(bnd_bag)
    }

    func resetUI(forState state: UIState) {
        switch state {
        case .ErrorLoading:
            tableView.hidden = true
        case .Loading:
            break
        case .DoneLoading:
            tableView.reloadData()
            tableView.hidden = false
            refreshControl?.endRefreshing()
        }
    }

    enum UIState {
        case Loading, DoneLoading, ErrorLoading
    }

    func addButtonTapped(sender: UIBarButtonItem) {
        appCoordinator.addButtonTapped()
    }

    func refreshControlValueChanged(sender: UIRefreshControl) {
        viewModel.refreshFeed()
    }
}

extension FeedVC {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.array.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = viewModel.items.array[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(FeedCell.description()) as! FeedCell
        cell._imageView.image = item
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let image = viewModel.items.array[indexPath.row]
        return rowHeight(from: image)
    }
}
