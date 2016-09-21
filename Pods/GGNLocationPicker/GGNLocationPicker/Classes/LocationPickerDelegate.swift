//
//  LocationPickerDelegate.swift
//  Pods
//
//  Created by Garric Nahapetian on 8/21/16.
//
//

import MapKit

public protocol LocationPickerDelegate: class {
    func didPickLocation(with annotation: MKAnnotation)
}