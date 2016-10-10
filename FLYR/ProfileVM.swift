//
//  ProfileVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/5/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import Bond

struct ProfileVM: FlyrViewModeling {
    let output = ObservableArray<Flyr>()
    let flyrFetcher: FlyrFetchable
    let alertOutput = EventProducer<UIAlertController>()
    let doneLoadingOutput = EventProducer<Void>()

    init(flyrFetcher: FlyrFetchable) {
        self.flyrFetcher = flyrFetcher

        self.flyrFetcher.output.observe {
            self.output.removeAll()
            self.output.extend($0)
            self.doneLoadingOutput.next()
        }

        self.flyrFetcher.errorOutput.observe { error in
            let alert = makeAlert(
                title: "Error fetching Profile Flyrs",
                message: "Error: \(error)"
            )
            self.alertOutput.next(alert)
        }
    }

    func refresh() {
        guard let ownerReference = AppCoordinator.sharedInstance.ownerReference() else { return }

        let predicate = NSPredicate(format: "ownerReference == %@", ownerReference)
        let query = CKQuery(recordType: "Flyr", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        flyrFetcher.fetch(
            with: operation,
            and: query
        )
    }
}
