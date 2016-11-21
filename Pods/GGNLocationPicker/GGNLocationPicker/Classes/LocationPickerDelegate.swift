//
//  GGNLocationPicker
//
//  LocationPickerDelegate.swift
//
//  Created by Garric Nahapetian on 8/21/16.
//
//

import MapKit

/// Conform to this protocol and set yourself as the delegate of a LocationPickerVC to be notified when the user selects a location.
public protocol LocationPickerDelegate: class {
    // MARK: - Methods
    /**
     This method is called when the user taps the + button of a callout of an MKAnnotationView.
     
     - parameter annotation: An object conforming to MKAnnotation which represents the location the user selected.
    */
    func didPick(annotation: MKAnnotation)
}
