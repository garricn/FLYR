//
//  FeedVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class FeedVM: FlyrViewModeling, FlyrConfigurable {

    var onModelUpdated: (() -> Void)?
    
    weak var delegate: FlyrViewModelingDelegate?

    private var model: Flyrs {
        didSet {
            onModelUpdated?()
        }
    }

    init(model: Flyrs) {
        self.model = model
    }
    
    func configure(with flyrs: [Flyr]) {
        model = flyrs
    }
    
    func refresh() {
        delegate?.refresh()
    }

    func didPullToRefresh() {
        delegate?.didPullToRefresh(in: self)
    }
    
    func didReceive(_ flyrs: Flyrs) {
        model = flyrs
    }

    func numberOfSections() -> Int {
        return 1
    }
    
    func numbersOfRows(inSection section: Int) -> Int {
        return model.count
    }
    
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let item = model[indexPath.row]
        let identifier = FlyrCell.identifier
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier)
        let cell = dequeuedCell as? FlyrCell ?? FlyrCell()
        cell._imageView.image = item.image
        return cell
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let image = model[indexPath.row].image
        return rowHeight(from: image)
    }
}
