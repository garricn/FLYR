//
//  ProfileVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/5/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import GGNObservable

class ProfileVM: FlyrViewModeling {
    let model: Flyrs = []
    let output = Observable<Flyrs>()
    let flyrFetcher: FlyrFetchable
    let alertOutput = Observable<UIAlertController>()
    let doneLoadingOutput = Observable<Void>()

    init(flyrFetcher: FlyrFetchable) {
        self.flyrFetcher = flyrFetcher

        self.flyrFetcher.output.onNext { [weak self] flyrs in
            self?.output.emit(flyrs)
            self?.doneLoadingOutput.emit()
        }

        self.flyrFetcher.errorOutput.onNext { [weak self] error in
            let alert = makeAlert(title: "Error fetching Profile Flyrs", message: "Error: \(error)")
            self?.alertOutput.emit(alert)
        }
    }

    func refresh() {
//        guard let ownerReference = AppCoordinator.sharedInstance.ownerReference() else { return }
//        let predicate = NSPredicate(format: "ownerReference == %@", ownerReference)
//        let query = CKQuery(recordType: "Flyr", predicate: predicate)
//        let operation = CKQueryOperation(query: query)
//        flyrFetcher.fetch(with: operation, and: query)
    }
}
