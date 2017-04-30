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
    
    // MARK: - FlyrConfigurable
    
    func configure(with flyrs: [Flyr]) {
        model = flyrs
    }
    
    // MARK: - FlyrViewModeling
    
    func refresh() {
        delegate?.refresh()
    }

    // MARK: - FlyrInteracting
    
    func didPullToRefresh() {
        delegate?.didPullToRefresh(in: self)
    }
    
    func didLongPress(sender: UILongPressGestureRecognizer, in tableView: UITableView) {
        guard sender.state == .began else {
            return
        }
        
        let pressPoint = sender.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: pressPoint) else {
            return
        }
        
        let flyr = model[indexPath.row]
        delegate?.didLongPress(on: flyr)
    }
    
    // MARK: - TableViewDataSource

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
