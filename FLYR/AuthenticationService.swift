//
//  AuthenticationService.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/5/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import Bond

struct AuthenticationService {
    let output = EventProducer<CKRecordID>()
    let errorOutput = EventProducer<ErrorType?>()
    let container: Container

    init(container: Container) {
        self.container = container

        container.fetchUserRecordID { response in
            guard case .Successful(let recordID as CKRecordID) = response else {
                if case .NotSuccessful(let error) = response {
                    self.errorOutput.next(error)
                }
                return
            }

            self.output.next(recordID)
        }
    }
}

protocol Container {
    func fetchUserRecordID(completion: (with: Response) -> Void)
}

extension CKContainer: Container {
    func fetchUserRecordID(completion: (with: Response) -> Void) {
        fetchUserRecordIDWithCompletionHandler { recordID, error in
            let response: Response

            if let recordID = recordID {
                response = .Successful(with: recordID)
            } else {
                let _error: ErrorType

                if let error = error {
                    _error = error
                } else {
                    _error = Error(message: "Unknown container error.")
                }

                response = .NotSuccessful(with: _error)
            }
            completion(with: response)
        }
    }
}