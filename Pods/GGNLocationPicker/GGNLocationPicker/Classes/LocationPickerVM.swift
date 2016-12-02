//
//  GGNLocationPicker
//
//  LocationPickerVM.swift
//
//  Created by Garric Nahapetian on 8/21/16.
//
//

import MapKit
import GGNObservable

class LocationPickerVM {
    let output = Observable<MKAnnotation>()
    let searchResultsOutput = Observable<[MKAnnotation]>()
    let longPressOutput = Observable<MKAnnotation>()
    let showUserLocationOutput = Observable<Void>()
    let alertOutput = Observable<UIAlertController>()
    let viewControllerOutput = Observable<UIViewController>()
    var shouldShowUserLocation: Bool

    fileprivate let locationService = LocationService()
    fileprivate let searchService = SearchService()

    init() {
        shouldShowUserLocation = locationService.enabledAndAuthorized

        locationService.authorizedOutput.onNext { [weak self] authorized in
            guard let _self = self else { return }

            if authorized {
                _self.showUserLocationOutput.emit()
            } else if _self.locationService.authorizationDenied {
                let alert = makeAlert()
                _self.alertOutput.emit(alert)
            }
        }
    }

    func searchButtonTapped<VC: UISearchBarDelegate>(from vc: VC) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = vc
        searchController.searchBar.placeholder = "Search for Place or Address"
        viewControllerOutput.emit(searchController)
    }

    func annotationView(fore annotation: MKAnnotation, of mapView: MKMapView) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            mapView.userLocation.subtitle = ""
            return nil
        }

        let reuseIdentifier = "PinView"
        let pinView: MKPinAnnotationView

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView {
            pinView = annotationView
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView.animatesDrop = false
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        }

        return pinView
    }

    func didSelect(_ annotationView: MKAnnotationView, of mapView: MKMapView) {
        guard
            let annotation = annotationView.annotation, annotation.isKind(of: MKUserLocation.self),
            let location = mapView.userLocation.location
            else { return }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else {
                print("Error: \(error)")
                return
            }

            if let addressDictionary = placemark.addressDictionary as? [String: AnyObject]
                , let formattedAddressLines = addressDictionary["FormattedAddressLines"] as? [String] {

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

    func didAdd(_ annotationViews: [MKAnnotationView], to mapView: MKMapView) {
        annotationViews.forEach { annotationView in
            if let annotation = annotationView.annotation, annotation.isKind(of: MKUserLocation.self) {
                annotationView.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            }
        }
    }

    func didTap(_ control: UIControl, of annotationView: MKAnnotationView, of mapView: MKMapView) {
        guard
            let annotation = annotationView.annotation, control == annotationView.rightCalloutAccessoryView
            else { return }
        output.emit(annotation)
    }

    func didTapSearchButton(of searchBar: UISearchBar, of mapView: MKMapView) {
        guard let text = searchBar.text else { return }

        searchService.search(with: text, and: mapView.userLocation) { response in
            let annotations = response.mapItems.map(toAnnotation)
            self.searchResultsOutput.emit(annotations)
        }
    }

    func handle(_ longPressGesture: UILongPressGestureRecognizer, on mapView: MKMapView) {
        guard longPressGesture.state == .began else { return }

        let pressPoint = longPressGesture.location(in: mapView)
        let coordinate = mapView.convert(pressPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let addressDictionary = placemarks?.first?.addressDictionary as? [String: AnyObject]
                , let addressLines = addressDictionary["FormattedAddressLines"] as? [String] {

                switch addressLines.count {
                case 0:
                    annotation.title = placemarks?.first?.name
                case 1:
                    annotation.title = addressLines[0]
                case 2:
                    annotation.title = addressLines[0]
                    annotation.subtitle = addressLines[1]
                default:
                    if addressLines[0] == addressLines[1] {
                        annotation.title = addressLines[1]
                        annotation.subtitle = addressLines[2]
                    } else {
                        annotation.title = addressLines[0]
                        if addressLines[2].contains("United States") {
                            annotation.subtitle = "\(addressLines[1])"
                        } else {
                            annotation.subtitle = "\(addressLines[1]), \(addressLines[2])"
                        }
                    }
                }
            } else {
                annotation.title = placemarks?.first?.name
            }
            self.longPressOutput.emit(annotation)
        }
    }

    func userLocationButtonTapped() {
        guard !locationService.enabledAndAuthorized else {
            return showUserLocationOutput.emit()
        }

        locationService.requestWhenInUse()
    }
}

func toAnnotation(from item: MKMapItem) -> MKPointAnnotation {
    let placemark = item.placemark
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    annotation.title = placemark.name

    if let addressDictionary = placemark.addressDictionary as? [String:AnyObject],
        let addressLines = addressDictionary["FormattedAddressLines"] as? [String], addressLines.count > 0 {

        switch addressLines.count {
        case 2:
            annotation.subtitle = addressLines[1]
        case 3:
            if placemark.name! != addressLines[0] {
                annotation.subtitle = addressLines[0]
            } else if addressLines[2].contains("United States") {
                annotation.subtitle = "\(addressLines[1])"
            } else {
                annotation.subtitle = "\(addressLines[1]), \(addressLines[2])"
            }
        default: break
        }
    }
    return annotation
}

func makeAlert() -> UIAlertController {
    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
    let openSettings = UIAlertAction(
        title: "Settings",
        style: .default,
        handler: { _ in
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.openURL(url)
        }
    )
    let alert = UIAlertController(
        title: "Location Services Authorization Denied",
        message: "Enable location services for this app in settings.",
        preferredStyle: .alert
    )
    alert.addAction(ok)
    alert.addAction(openSettings)
    return alert
}
