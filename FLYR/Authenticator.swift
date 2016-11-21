//
//  Authenticator.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/5/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import Bond

protocol Authenticating {
    func authenticate(completion: (CKReference?, ErrorType?) -> Void)
    func ownerReference() -> CKReference?
}

class Authenticator: Authenticating {
    private let container: Container
    private var user: User?

    init(defaultContainer: Container) {
        self.container = defaultContainer

        container.fetchUserRecordID { response in
            guard case .Successful(let recordID as CKRecordID) = response else { return }
            let reference = CKReference(recordID: recordID, action: .None)
            self.user = User(ownerReference: reference)
        }
    }

    func ownerReference() -> CKReference? {
        return user?.ownerReference
    }

    func authenticate(completion: (CKReference?, ErrorType?) -> Void) {
        guard user == nil else { return completion(user!.ownerReference, nil) }

        container.fetchUserRecordID { response in
            guard case .Successful(let recordID as CKRecordID) = response else {
                if case .NotSuccessful(let error) = response {
                    return completion(nil, error)
                }
                return completion(nil, nil)
            }

            let reference = CKReference(recordID: recordID, action: .None)
            completion(reference, nil)
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