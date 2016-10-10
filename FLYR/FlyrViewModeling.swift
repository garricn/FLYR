//
//  FlyrViewModeling.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/8/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Bond
import CoreLocation
import MapKit

protocol FlyrViewModeling: AlertOutputing, FlyrOutputing, FlyrInteractionHandling, TableViewDataSource {}

protocol AlertOutputing {
    var alertOutput: EventProducer<UIAlertController> { get }
}

protocol FlyrOutputing {
    var output: ObservableArray<Flyr> { get }
    var flyrFetcher: FlyrFetchable { get }
    var doneLoadingOutput: EventProducer<Void> { get }
}

protocol FlyrInteractionHandling {
    func refresh()
    func onLongPress(at indexPath: NSIndexPath, from vc: FlyrTableVC)
}

protocol TableViewDataSource {
    func numberOfSections() -> Int
    func numbersOfRows(inSection section: Int) -> Int
    func cellForRow(at indexPath: NSIndexPath, en tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: NSIndexPath) -> CGFloat
}

// MARK: - Interactivity
extension FlyrViewModeling {
    func onLongPress(at indexPath: NSIndexPath, from vc: FlyrTableVC) {
        let item = output.array[indexPath.row]
        let actionSheet = makeActionSheet(on: item, fore: vc)
        alertOutput.next(actionSheet)
    }

    private func makeActionSheet(on item: Flyr, fore vc: UIViewController) -> UIAlertController {
        let save = UIAlertAction(
            title: "Save",
            style: .Default
        ) { _ in
            UIImageWriteToSavedPhotosAlbum(item.image, nil, nil, nil)
        }

        let share = UIAlertAction(
            title: "Share",
            style: .Default
        ) { _ in
            let shareSheet = UIActivityViewController(
                activityItems: [item.image],
                applicationActivities: nil
            )
            vc.presentViewController(shareSheet, animated: true, completion: nil)
        }

        let directions = UIAlertAction(title: "Directions", style: .Default) { _ in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(item.location) { placemarks, error in
                if let placemark = placemarks?.first {
                    let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                    mapItem.openInMapsWithLaunchOptions(nil)
                } else {
                    print("Error reverse geocoding: \(error)")
                }
            }
        }

        let cancel = UIAlertAction(
            title: "Cancel",
            style: .Cancel,
            handler: nil
        )

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
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
        return output.array.count
    }

    func cellForRow(at indexPath: NSIndexPath, en tableView: UITableView) -> UITableViewCell {
        let item = output.array[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(FlyrCell.description()) as! FlyrCell
        cell._imageView.image = item.image
        return cell
    }

    func heightForRow(at indexPath: NSIndexPath) -> CGFloat {
        let image = output.array[indexPath.row].image
        return rowHeight(from: image)
    }
}
