//
//  FeedView.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond
import Cartography

class FeedView: BaseView {
    let tableView = UITableView()

    override func setup() {
        tableView.registerClass(
            FeedCell.self,
            forCellReuseIdentifier: FeedCell.description()
        )
        addSubview(tableView)
    }

    override func style() {
        backgroundColor = .whiteColor()
        
        tableView
            .estimatedRowHeight = UIScreen
            .mainScreen()
            .bounds
            .width
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func layout() {
        constrain(tableView) { tableView in
            tableView.top == tableView.superview!.top + 8
            tableView.leading == tableView.superview!.leading + 8
            tableView.trailing == tableView.superview!.trailing - 8
            tableView.bottom == tableView.superview!.bottom - 8
        }
    }
}

//extension FeedView: UITableViewDelegate {
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let image = Model.sharedInstance.items[indexPath.row].image
//        let ratio = image.size.height / image.size.width
//        return (view.bounds.width * ratio) //+ 88
//    }
//}





