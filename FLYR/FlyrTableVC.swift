//
//  FlyrTableVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/8/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import GGNObservable

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
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "◉",
            style: .plain,
            target: self,
            action: #selector(locationButtonTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(onPullToRefresh),
            for: .valueChanged
        )

        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onLongPress)
        )
        tableView.addGestureRecognizer(longPressGestureRecognizer)
        tableView.showsVerticalScrollIndicator = false
        tableView.alpha = 0.0
        tableView.register(
            FlyrCell.self,
            forCellReuseIdentifier: FlyrCell.identifier
        )
    }

    func setupObservers() {
        viewModel.alertOutput.onNext { alertController in
            self.present(alertController, animated: true) {
                if alertController.preferredStyle == .alert {
                    self.resetUI(forState: .errorLoading)
                }
            }
        }

        DispatchQueue.main.async {
            self.viewModel.doneLoadingOutput.onNext {
                self.resetUI(forState: .doneLoading)
            }
        }
    }

    func resetUI(forState state: LoadingState) {
        switch state {
        case .errorLoading:
            tableView.alpha = 0.0
        case .loading:
            break
        case .doneLoading:
            tableView.reloadData()
            refreshControl?.endRefreshing()
            if tableView.alpha == 0.0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.alpha = 1.0
                }) 
            }
        }
    }
}

// MARK: - Interactivity
extension FlyrTableVC {
    func locationButtonTapped(_ sender: UIBarButtonItem) {
        AppCoordinator.sharedInstance.locationButtonTapped()
    }

    func addButtonTapped(_ sender: UIBarButtonItem) {
        AppCoordinator.sharedInstance.addButtonTapped()
    }

    func onPullToRefresh(_ sender: UIRefreshControl) {
        viewModel.refresh()
    }

    func onLongPress(_ sender: UILongPressGestureRecognizer) {
        let pressPoint = sender.location(in: tableView)

        guard let indexPath = tableView.indexPathForRow(at: pressPoint), sender.state == .began else {
            return
        }

        viewModel.onLongPress(at: indexPath, from: self)
    }
}

extension FlyrTableVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellForRow(at: indexPath, en: tableView)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath)
    }
}

enum LoadingState {
    case loading, doneLoading, errorLoading
}
