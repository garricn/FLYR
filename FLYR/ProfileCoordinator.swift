//
//  ProfileCoordinator.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit
import GGNLocationPicker
import MapKit

class ProfileCoordinator: NSObject, Coordinator, FlyrViewModelingDelegate {
    weak var delegate: CoordinatorDelegate?
    
    let rootViewController: UIViewController
    
    private let fetcher: FlyrFetchable
    private let appState: ProfileAppState
    private let viewModel: FlyrConfigurable
    
    private var navigationController: UINavigationController {
        if let viewController = rootViewController as? UINavigationController {
            return viewController
        } else {
            fatalError("Expects a UINavigationController!")
        }
    }
    
    init(appState: ProfileAppState, fetcher: FlyrFetchable) {
        self.appState = appState
        self.fetcher = fetcher
        
        let viewModel = ProfileVM(model: [])
        let viewController = FlyrTableVC(viewModel: viewModel)
        self.rootViewController = UINavigationController(rootViewController: viewController)
        self.viewModel = viewModel
        
        super.init()
        
        self.viewModel.delegate = self
    }

    func refresh() {
        guard let reference = appState.ownerReference else {
            return
        }
        
        fetcher.output.onNext { [weak self] flyrs in
            self?.viewModel.configure(with: flyrs)
        }
        
        fetcher.errorOutput.onNext { error in
            print(error!)
        }
        
        let predicate = NSPredicate(format: "ownerReference == %@", reference)
        let query = CKQuery(recordType: "Flyr", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        fetcher.fetch(with: operation, and: query)
    }
    
    func didPullToRefresh(in viewModel: FlyrConfigurable) {
        refresh()
    }
    
    func didLongPress(on flyr: Flyr) {
        let save = UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            UIImageWriteToSavedPhotosAlbum(
                flyr.image,
                self,
                #selector(self?.image(_:didFinishSavingWithError:contextInfo:)),
                nil
            )
        })
        
        let share = UIAlertAction(title: "Share", style: .default, handler: { [weak self] _ in
            let items = [flyr.image]
            let shareSheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self?.rootViewController.present(shareSheet, animated: true, completion: nil)
        })
        
        let directions = UIAlertAction(title: "Directions", style: .default, handler: { _ in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(flyr.location) { placemarks, error in
                if let placemark = placemarks?.first {
                    let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                    mapItem.openInMaps(launchOptions: nil)
                } else {
                    assertionFailure("Unable to reverse geocode location!")
                }
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        [save, share, directions, cancel].forEach({ alertController.addAction($0) })
        
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        let message: String
        
        if let error = error {
            message = "Error saving photo: \(error). Please try again later."
        } else {
            message = "Photo saved."
        }
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        rootViewController.present(alertController, animated: true, completion: nil)
    }
}
