//
//  FlyrTableVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/8/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond

class FlyrTableVC: UITableViewController {
    var viewModel: FlyrViewModeling

    init(viewModel: FlyrViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.viewModel = resolvedFeedVM()
        super.init(coder: aDecoder)
    }
}

// MARK: - View Lifecycle
extension FlyrTableVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObservers()
        viewModel.refresh()
    }

    func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: #selector(addButtonTapped)
        )

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(onPullToRefresh),
            forControlEvents: .ValueChanged
        )

        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onLongPress)
        )
        tableView.addGestureRecognizer(longPressGestureRecognizer)
        tableView.showsVerticalScrollIndicator = false
        tableView.alpha = 0.0
        tableView.registerClass(
            FlyrCell.self,
            forCellReuseIdentifier: FlyrCell.identifier
        )
    }

    func setupObservers() {
        viewModel
            .alertOutput
            .deliverOn(.Main)
            .observe { alertController in
                self.presentViewController(
                    alertController,
                    animated: true,
                    completion: {
                        if alertController.preferredStyle == .Alert {
                            self.resetUI(forState: .ErrorLoading)
                        }
                    }
                )
            }.disposeIn(bnd_bag)

        viewModel
            .doneLoadingOutput
            .deliverOn(.Main)
            .observe {
                self.resetUI(forState: .DoneLoading)
            }.disposeIn(bnd_bag)
    }

    func resetUI(forState state: LoadingState) {
        switch state {
        case .ErrorLoading:
            tableView.alpha = 0.0
        case .Loading:
            break
        case .DoneLoading:
            tableView.reloadData()
            refreshControl?.endRefreshing()
            if tableView.alpha == 0.0 {
                UIView.animateWithDuration(
                    0.3,
                    animations: { self.tableView.alpha = 1.0 }
                )
            }
        }
    }
}

// MARK: - Interactivity
extension FlyrTableVC {
    func addButtonTapped(sender: UIBarButtonItem) {
        AppCoordinator.sharedInstance.addButtonTapped()
    }

    func onPullToRefresh(sender: UIRefreshControl) {
        viewModel.refresh()
    }

    func onLongPress(sender: UILongPressGestureRecognizer) {
        let pressPoint = sender.locationInView(tableView)

        guard
            let indexPath = tableView.indexPathForRowAtPoint(pressPoint)
            where sender.state == .Began
            else { return }

        viewModel.onLongPress(at: indexPath, from: self)
    }
}

extension FlyrTableVC {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersOfRows(inSection: section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return viewModel.cellForRow(at: indexPath, en: tableView)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath)
    }
}

enum LoadingState {
    case Loading, DoneLoading, ErrorLoading
}
