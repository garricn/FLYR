//
//  FeedVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond

class FeedVC: UIViewController {
    let viewModel: FeedVM
    let feedView: FeedView

    private var tableView: UITableView { return feedView.tableView }
    private var spinner: UIActivityIndicatorView { return feedView.spinner }

    init(feedVM: FeedVM, feedView: FeedView) {
        self.viewModel = feedVM
        self.feedView = feedView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.feedView = FeedView()
        self.viewModel = FeedVM(
            flyrFetcher: FlyrFetcher(database: resolvedPublicDatabase()),
            locationManager: LocationManager()
        )
        super.init(coder: aDecoder)
    }

    override func loadView() {
        view = feedView
        tabBarItem = UITabBarItem(title: "FEED", image: nil, tag: 0)
        tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -8.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        viewModel
            .alertOutput
            .deliverOn(Queue.Main)
            .observe { alertController in
                self.presentViewController(
                    alertController,
                    animated: true,
                    completion: { self.resetUI(forState: .ErrorLoading) })
            }.disposeIn(bnd_bag)

        viewModel
            .imageOutput
            .deliverOn(Queue.Main)
            .lift()
            .bindTo(tableView) { indexPath, dataSource, tableView in
                let image = dataSource[indexPath.section][indexPath.row]
                let cell = tableView
                    .dequeueReusableCellWithIdentifier(
                        FeedCell.description(),
                        forIndexPath: indexPath
                    ) as! FeedCell

                cell._imageView.image = image
                self.resetUI(forState: .DoneLoading)
                return cell
            }

        viewModel.refreshFeed()
    }

    func resetUI(forState state: UIState) {
        switch state {
        case .ErrorLoading:
            tableView.hidden = true
            spinner.stopAnimating()
        case .Loading:
            tableView.hidden = true
            spinner.startAnimating()
        case .DoneLoading:
            tableView.hidden = false
            spinner.stopAnimating()
        }
    }

    enum UIState {
        case Loading, DoneLoading, ErrorLoading
    }
}

extension FeedVC: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let image = viewModel.imageOutput.array[indexPath.row]
        let ratio = image.size.height / image.size.width
        return view.bounds.width * ratio
    }
}
