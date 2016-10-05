//
//  FeedVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond
import CoreLocation
import MapKit

class FeedVC: UITableViewController {
    let viewModel: FeedVM

    init(feedVM: FeedVM) {
        self.viewModel = feedVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = FeedVM(
            flyrFetcher: FlyrFetcher(database: resolvedPublicDatabase()),
            locationManager: LocationManager()
        )
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObservers()
        resetUI(forState: .Loading)
        viewModel.refreshFeed()
    }

    func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: #selector(addButtonTapped)
        )

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(refreshControlValueChanged),
            forControlEvents: .ValueChanged
        )

        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onLongPress)
        )
        tableView.addGestureRecognizer(longPressGestureRecognizer)
        tableView.showsVerticalScrollIndicator = false
        tableView.alpha = 0.0
        tableView.registerClass(
            FeedCell.self,
            forCellReuseIdentifier: FeedCell.description()
        )
    }

    func setupObservers() {
        viewModel
            .alertOutput
            .deliverOn(Queue.Main)
            .observe { alertController in
                self.presentViewController(
                    alertController,
                    animated: true,
                    completion: { self.resetUI(forState: .ErrorLoading) }
                )
            }.disposeIn(bnd_bag)

        viewModel
            .doneLoadingOutput
            .deliverOn(Queue.Main)
            .observe {
                self.resetUI(forState: .DoneLoading)
            }.disposeIn(bnd_bag)
    }

    func resetUI(forState state: UIState) {
        switch state {
        case .ErrorLoading:
            tableView.alpha = 0.0
        case .Loading:
            break
        case .DoneLoading:
            tableView.reloadData()
            refreshControl?.endRefreshing()
            if tableView.alpha == 0.0 {
                UIView.animateWithDuration(
                    0.3,
                    animations: { self.tableView.alpha = 1.0 }
                )
            }
        }
    }

    enum UIState {
        case Loading, DoneLoading, ErrorLoading
    }

    func addButtonTapped(sender: UIBarButtonItem) {
        appCoordinator.addButtonTapped()
    }

    func refreshControlValueChanged(sender: UIRefreshControl) {
        viewModel.refreshFeed()
    }
}

extension FeedVC {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.flyrOutput.array.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = viewModel.flyrOutput.array[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(FeedCell.description()) as! FeedCell
        cell._imageView.image = item.image
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let image = viewModel.flyrOutput.array[indexPath.row].image
        return rowHeight(from: image)
    }
}

extension FeedVC {
    func onLongPress(sender: UILongPressGestureRecognizer) {
        guard
            let indexPath = tableView.indexPathForRowAtPoint(sender.locationInView(tableView))
            where sender.state == .Began
            else { return }

        let item = viewModel.flyrOutput.array[indexPath.row]
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
            self.presentViewController(shareSheet, animated: true, completion: nil)
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
        presentViewController(alertController, animated: true, completion: nil)
    }
}
