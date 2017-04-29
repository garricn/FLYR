//
//  AppState.swift
//  FLYR
//
//  Created by Garric G. Nahapetian on 3/26/17.
//  Copyright © 2017 Garric Nahapetian. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import MapKit

final class AppState: NSObject, NSCoding {
    
    let launchReason: LaunchReason
    
    var isExistingUser: Bool = false
    var feedMode: FeedMode = .losAngeles
    var ownerReference: CKReference?
    
    private static let archiveURL = AppState.documentsDirectoryURL.appendingPathComponent("appState")
    private static var documentsDirectoryURL: URL {
        if let URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return URL
        } else {
            fatalError("Expects a documents directory URL!")
        }
    }
    
    init(isExistingUser: Bool, feedMode: FeedMode?, launchReason: LaunchReason = .normal) {
        self.isExistingUser = isExistingUser
        self.feedMode = feedMode ?? .losAngeles
        self.launchReason = launchReason
    }

    convenience init(launchReason: LaunchReason) {
        let file = AppState.archiveURL.path
        let unarchivedObject = NSKeyedUnarchiver.unarchiveObject(withFile: file)
        
        guard let appState = unarchivedObject as? AppState else {
            self.init(isExistingUser: false, feedMode: nil, launchReason: launchReason)
            return
        }
        
        let isExistingUser = appState.isExistingUser
        let feedMode = appState.feedMode
        self.init(isExistingUser: isExistingUser, feedMode: feedMode, launchReason: launchReason)
    }
    
    convenience init?(coder aDecoder: NSCoder) {
        let feedModeInteger = aDecoder.decodeInteger(forKey: Keys.feedMode)
        let preferredInteger = FeedMode.preferred(MKPointAnnotation()).integerValue
        let annotation = MKPointAnnotation()
        
        if feedModeInteger == preferredInteger {
            let latitude = aDecoder.decodeDouble(forKey: Keys.latitude)
            let longitude = aDecoder.decodeDouble(forKey: Keys.longitude)
            let annotationTitle = aDecoder.decodeObject(forKey: Keys.annotationTitle) as? String ?? ""
            let annotationSubtitle = aDecoder.decodeObject(forKey: Keys.annotationSubtitle) as? String ?? ""
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = coordinate
            annotation.title = annotationTitle
            annotation.subtitle = annotationSubtitle            
        }

        let feedMode = FeedMode.init(integer: feedModeInteger, annotation: annotation)
        let isExistingUser = aDecoder.decodeBool(forKey: Keys.isExistingUser)
        
        self.init(isExistingUser: isExistingUser, feedMode: feedMode)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(isExistingUser, forKey: Keys.isExistingUser)
        aCoder.encode(feedMode.integerValue, forKey: Keys.feedMode)

        if case let .preferred(annotation) = feedMode {
            let latitude = annotation.coordinate.latitude
            let longitude = annotation.coordinate.longitude
            let annotationTitle = (annotation.title ?? "") ?? ""
            let annotationSubtitle = (annotation.subtitle ?? "") ?? ""
            aCoder.encode(latitude, forKey: Keys.latitude)
            aCoder.encode(longitude, forKey: Keys.longitude)
            aCoder.encode(annotationTitle, forKey: Keys.annotationTitle)
            aCoder.encode(annotationSubtitle, forKey: Keys.annotationSubtitle)
        }        
    }
    
    func onboardingCompleted(with selectedFeedMode: FeedMode) {
        isExistingUser = true
        feedMode = selectedFeedMode
        archive()
    }
    
    func authenticationCompleted(with reference: CKReference) {
        ownerReference = reference
    }
    
    fileprivate func archive() {
        DispatchQueue.global().async {
            NSKeyedArchiver.archiveRootObject(self, toFile: AppState.archiveURL.path)
        }
    }
    
    // MARK: - Nested Types
    
    private struct Keys {
        static let isExistingUser = "isExistingUser"
        static let feedMode = "feedMode"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let annotationTitle = "annotationTitle"
        static let annotationSubtitle = "annotationSubtitle"
    }
}

protocol FeedAppState {
    var feedMode: FeedMode { get }
    func didReceive(userLocation: CLLocation)
    func didSelect(newFeedMode mode: FeedMode)
}

extension AppState: FeedAppState {
    
    func didSelect(newFeedMode mode: FeedMode) {
        feedMode = mode
        archive()
    }
    
    func didReceive(userLocation: CLLocation) {
        if case .userLocation(_) = feedMode {
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation.coordinate
            annotation.title = "Current Location"
            feedMode = .userLocation(annotation)
        }
    }
}

protocol ProfileAppState {
    var ownerReference: CKReference? { get }
}

extension AppState: ProfileAppState {}
