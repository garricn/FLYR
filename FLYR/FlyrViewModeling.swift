//
//  FlyrViewModeling.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/8/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import GGNObservable
import CoreLocation
import MapKit

protocol FlyrViewModeling: TableViewDataSource {
    var model: Flyrs { get }
}

protocol TableViewDataSource {
    func numberOfSections() -> Int
    func numbersOfRows(inSection section: Int) -> Int
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: IndexPath) -> CGFloat
}

extension FlyrViewModeling {

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
