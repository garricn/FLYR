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

// MARK: - Flyr TableView Data Source
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


//// MARK: - Interactivity
//extension FlyrViewModeling {
//    func onLongPress(at indexPath: IndexPath, from vc: FlyrTableVC) {
//        let item = model[indexPath.row]
//        let actionSheet = makeActionSheet(on: item, for: vc)
////        alertOutput.emit(actionSheet)
//    }
//
//    fileprivate func makeActionSheet(on item: Flyr, for vc: UIViewController) -> UIAlertController {
//        let save = UIAlertAction(
//            title: "Save",
//            style: .default
//        ) { _ in
//            UIImageWriteToSavedPhotosAlbum(item.image, nil, nil, nil)
//        }
//
//        let share = UIAlertAction(
//            title: "Share",
//            style: .default
//        ) { _ in
//            let shareSheet = UIActivityViewController(
//                activityItems: [item.image],
//                applicationActivities: nil
//            )
//            vc.present(shareSheet, animated: true, completion: nil)
//        }
//
//        let directions = UIAlertAction(title: "Directions", style: .default) { _ in
//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(item.location) { placemarks, error in
//                if let placemark = placemarks?.first {
//                    let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
//                    mapItem.openInMaps(launchOptions: nil)
//                } else {
//                    print("Error reverse geocoding: \(error)")
//                }
//            }
//        }
//
//        let cancel = UIAlertAction(
//            title: "Cancel",
//            style: .cancel,
//            handler: nil
//        )
//
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alertController.addAction(save)
//        alertController.addAction(share)
//        alertController.addAction(directions)
//        alertController.addAction(cancel)
//
//        return alertController
//    }
//}

