//
//  LocationPickerVM.swift
//  Pods
//
//  Created by Garric Nahapetian on 8/21/16.
//
//

import MapKit

class LocationPickerVM {
    let alertOutput = Observable<UIAlertController>()
    var shouldShowUserLocation: Bool

    private let locationService = LocationService()
    private let searchService = SearchService()

    init() {
        shouldShowUserLocation = locationService.enabledAndAuthorized
    }

    func userLocationRequested(with completion: (shouldShowUserLocation: Bool) -> Void) {
        guard !locationService.enabledAndAuthorized else {
            return completion(shouldShowUserLocation: true)
        }

        locationService.requestWhenInUse {
            completion(shouldShowUserLocation: $0)

            if self.locationService.authorizationDenied {
                let alert = makeAlert()
                self.alertOutput.next(alert)
            }
        }
    }

    func searchRequested(with text: String, and location: MKUserLocation, with completion: ([MKPointAnnotation]) -> Void) {
        searchService.search(with: text, and: location) { response in
            guard response.mapItems.count > 0 else { return }
            let annotations = response.mapItems.map(toAnnotation)
            completion(annotations)
        }
    }
}

func toAnnotation(from item: MKMapItem) -> MKPointAnnotation {
    let placemark = item.placemark
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    annotation.title = placemark.name

    if let addressDictionary = placemark.addressDictionary as? [String:AnyObject],
        addressLines = addressDictionary["FormattedAddressLines"] as? [String]
        where addressLines.count > 0 {

        switch addressLines.count {
        case 2:
            annotation.subtitle = addressLines[1]
        case 3:
            if placemark.name! != addressLines[0] {
                annotation.subtitle = addressLines[0]
            } else if addressLines[2].containsString("United States") {
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
    let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
    let openSettings = UIAlertAction(
        title: "Settings",
        style: .Default,
        handler: { _ in
            guard let url = NSURL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.sharedApplication().openURL(url)
        }
    )
    let alert = UIAlertController(
        title: "Location Services Authorization Denied",
        message: "Enable location services for this app in settings.",
        preferredStyle: .Alert
    )
    alert.addAction(ok)
    alert.addAction(openSettings)
    return alert
}
