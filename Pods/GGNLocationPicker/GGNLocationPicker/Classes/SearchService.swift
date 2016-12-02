//  GGNLocationPicker
//
//  SearchService.swift
//
//  Created by Garric Nahapetian on 9/9/16.
//
//

import MapKit

struct SearchService {
    func search(with text: String, and location: MKUserLocation, with completion: @escaping (MKLocalSearchResponse) -> Void) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = text
        request.region = region(from: location)
        let search = MKLocalSearch(request: request)
        search.start { respone, error in
            guard
                let response = respone, response.mapItems.count > 0
                else { return }

            DispatchQueue.main.async {
                completion(response)
            }
        }
    }

    func region(from location: MKUserLocation) -> MKCoordinateRegion {
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegionMake(center, span)
        return region
    }
}
