//
//  LocationPickerViewController.swift
//  Pods
//
//  Created by Garric Nahapetian on 8/20/16.
//
//

import UIKit
import MapKit

public final class LocationPickerVC: UIViewController {
    public weak var pickerDelegate: LocationPickerDelegate?
    public var didPickLocation: ((with: MKAnnotation) -> Void)?

    private let viewModel = LocationPickerVM()
    private let mapView = MKMapView()
    private var userLocation: MKUserLocation { return mapView.userLocation }

    override public func loadView() {
        view = mapView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.toolbarHidden = false

        if presentingViewController != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Cancel,
                target: self,
                action: #selector(cancelButtonTapped)
            )
        }

        setToolbarItems()
        mapView.showsUserLocation = viewModel.shouldShowUserLocation
        mapView.delegate = self

        viewModel.alertOutput.observe { [weak self] alert in
            self?.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func cancelButtonTapped(sender: UIBarButtonItem) {
        parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    private func setToolbarItems() {
        let userLocationButton = UIBarButtonItem(
            title: "◉",
            style: .Plain,
            target: self,
            action: #selector(userLocationButtonTapped)
        )

        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .FlexibleSpace,
            target: nil,
            action: nil
        )

        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .Search,
            target: self,
            action: #selector(searchButtonTapped)
        )

        let items = [
            userLocationButton,
            flexSpace,
            searchButton
        ]

        setToolbarItems(
            items,
            animated: false
        )
    }
}

extension LocationPickerVC: MKMapViewDelegate {
    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKindOfClass(MKUserLocation.self) else {
            mapView.userLocation.subtitle = ""
            return nil
        }

        let reuseIdentifier = "PinView"
        let pinView: MKPinAnnotationView

        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView {
            pinView = annotationView
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView.animatesDrop = false
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = UIButton(type: .ContactAdd)
        }

        return pinView
    }

    public func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let annotation = view.annotation
            where annotation.isKindOfClass(MKUserLocation) else { return }

        guard let location = mapView.userLocation.location else { return }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else {
                print("Error: \(error)")
                return
            }

            if let addressDictionary = placemark.addressDictionary as? [String: AnyObject]
                , formattedAddressLines = addressDictionary["FormattedAddressLines"] as? [String] {

                if formattedAddressLines[0] == formattedAddressLines[1] {
                    mapView.userLocation.subtitle = "\(formattedAddressLines[0]), \(formattedAddressLines[1])"
                } else {
                    mapView.userLocation.title = "\(formattedAddressLines[0]) (Current Location)"
                    mapView.userLocation.subtitle = "\(formattedAddressLines[1]), \(formattedAddressLines[2])"
                }
            } else if let name = placemark.name {
                mapView.userLocation.title = "\(name) (Current Location)"
            }
        }
    }

    public func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        views.forEach { view in
            if let annotation = view.annotation
                where annotation.isKindOfClass(MKUserLocation) {
                view.rightCalloutAccessoryView = UIButton(type: .ContactAdd)
            }
        }
    }

    public func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation where control == view.rightCalloutAccessoryView else { return }

        didPickLocation?(with: annotation)
        pickerDelegate?.didPickLocation(with: annotation)
    }
}

extension LocationPickerVC: UISearchBarDelegate {
    @objc private func searchButtonTapped() {
        presentSearchController()
    }

    private func presentSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for Place or Address"
        presentViewController(searchController, animated: true, completion: nil)
    }

    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        defer {
            dismissViewControllerAnimated(true, completion: nil)
        }

        guard let text = searchBar.text else { return }

        viewModel.searchRequested(with: text, and: userLocation) { annotations in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
            self.mapView.showAnnotations(annotations, animated: false)
            self.mapView.selectAnnotation(annotations.last!, animated: true)
        }
    }
}

extension LocationPickerVC {
    @objc private func userLocationButtonTapped() {
        viewModel.userLocationRequested { [weak self] shouldShowUserLocation in
            guard shouldShowUserLocation else { return }
            self?.mapView.setUserTrackingMode(.Follow, animated: true)
        }
    }
}
