//
//  FeedView.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Cartography

class FeedView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.hidden = true
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = screenWidth
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentOffset = CGPoint(x: 0.0, y: 64.0)
        tableView.registerClass(
            FeedCell.self,
            forCellReuseIdentifier: FeedCell.description()
        )
        return tableView
    }()

    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.hidden = true
        spinner.startAnimating()
        return spinner
    }()

    override func setup() {
        addSubview(spinner)
        addSubview(tableView)
    }

    override func style() {
        backgroundColor = .whiteColor()
    }

    override func layout() {
        constrain(spinner) { spinner in
            spinner.center == spinner.superview!.center
        }

        constrain(tableView) { tableView in
            tableView.top == tableView.superview!.top + 8
            tableView.leading == tableView.superview!.leading + 8
            tableView.trailing == tableView.superview!.trailing - 8
            tableView.bottom == tableView.superview!.bottom - 8
        }
    }
}
