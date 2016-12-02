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
    let output = Observable<Flyrs>()
    let flyrFetcher: FlyrFetchable
    let alertOutput = Observable<UIAlertController>()
    let doneLoadingOutput = Observable<Void>()

    init(flyrFetcher: FlyrFetchable) {
        self.flyrFetcher = flyrFetcher

        self.flyrFetcher.output.onNext {
//            self.output.removeAll()
            self.output.emit($0)
            self.doneLoadingOutput.emit()
        }

        self.flyrFetcher.errorOutput.onNext { error in
            let alert = makeAlert(
                "Error fetching Profile Flyrs",
                message: "Error: \(error)"
            )
            self.alertOutput.emit(alert)
        }
    }

    func refresh() {
        guard let ownerReference = AppCoordinator.sharedInstance.ownerReference() else { return }

        let predicate = NSPredicate(format: "ownerReference == %@", ownerReference)
        let query = CKQuery(recordType: "Flyr", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        flyrFetcher.fetch(with: operation, and: query)
    }
}
