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

protocol FlyrViewModeling: AlertOutputing, FlyrOutputing, FlyrInteractionHandling, TableViewDataSource {}

protocol AlertOutputing {
    var alertOutput: Observable<UIAlertController> { get }
}

protocol FlyrOutputing {
    var output: Observable<Flyrs> { get }
    var doneLoadingOutput: Observable<Void> { get }
}

protocol FlyrInteractionHandling {
    func refresh()
    func onLongPress(at indexPath: IndexPath, from vc: FlyrTableVC)
}

protocol TableViewDataSource {
    func numberOfSections() -> Int
    func numbersOfRows(inSection section: Int) -> Int
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: IndexPath) -> CGFloat
}

// MARK: - Interactivity
extension FlyrViewModeling {
    func onLongPress(at indexPath: IndexPath, from vc: FlyrTableVC) {
        let item = output.lastEvent?[indexPath.row]
        let actionSheet = makeActionSheet(on: item!, for: vc)
        alertOutput.emit(actionSheet)
    }

    fileprivate func makeActionSheet(on item: Flyr, for vc: UIViewController) -> UIAlertController {
        let save = UIAlertAction(
            title: "Save",
            style: .default
        ) { _ in
            UIImageWriteToSavedPhotosAlbum(item.image, nil, nil, nil)
        }

        let share = UIAlertAction(
            title: "Share",
            style: .default
        ) { _ in
            let shareSheet = UIActivityViewController(
                activityItems: [item.image],
                applicationActivities: nil
            )
            vc.present(shareSheet, animated: true, completion: nil)
        }

        let directions = UIAlertAction(title: "Directions", style: .default) { _ in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(item.location) { placemarks, error in
                if let placemark = placemarks?.first {
                    let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                    mapItem.openInMaps(launchOptions: nil)
                } else {
                    print("Error reverse geocoding: \(error)")
                }
            }
        }

        let cancel = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(save)
        alertController.addAction(share)
        alertController.addAction(directions)
        alertController.addAction(cancel)

        return alertController
    }
}

// MARK: - Flyr TableView Data Source
extension FlyrViewModeling {
    func numberOfSections() -> Int {
        return 1
    }

    func numbersOfRows(inSection section: Int) -> Int {
        return output.lastEvent?.count ?? 0
    }

    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let item = output.lastEvent?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FlyrCell.description()) as! FlyrCell
        cell._imageView.image = item?.image
        return cell
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let image = output.lastEvent?[indexPath.row].image
        return rowHeight(from: image!)
    }
}
