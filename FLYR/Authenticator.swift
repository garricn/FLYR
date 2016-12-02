//
//  Authenticator.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/5/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import GGNObservable

protocol Authenticating {
    func authenticate(completion: @escaping (CKReference?, Error?) -> Void)
    func ownerReference() -> CKReference?
}

class Authenticator: Authenticating {
    fileprivate let container: Container
    fileprivate var user: User?

    init(defaultContainer: Container) {
        self.container = defaultContainer

        container.fetchUserRecordID { response in
            guard case .successful(let recordID as CKRecordID) = response else { return }
            let reference = CKReference(recordID: recordID, action: .none)
            self.user = User(ownerReference: reference)
        }
    }

    func ownerReference() -> CKReference? {
        return user?.ownerReference
    }

    func authenticate(completion: @escaping (CKReference?, Error?) -> Void) {
        guard user == nil else { return completion(user!.ownerReference, nil) }

        container.fetchUserRecordID { response in
            guard case .successful(let recordID as CKRecordID) = response else {
                if case .notSuccessful(let error) = response {
                    return completion(nil, error)
                }
                return completion(nil, nil)
            }

            let reference = CKReference(recordID: recordID, action: .none)
            completion(reference, nil)
        }
    }
}

protocol Container {
    func fetchUserRecordID(completion: @escaping (Response) -> Void)
}

extension CKContainer: Container {
    func fetchUserRecordID(completion: @escaping (Response) -> Void) {
        self.fetchUserRecordID { recordID, error in
            let response: Response

            if let recordID = recordID {
                response = .successful(recordID)
            } else {
                let _error: Error

                if let error = error {
                    _error = error
                } else {
                    _error = GGNError(message: "Unknown container error.")
                }

                response = .notSuccessful(_error)
            }
            completion(response)
        }
    }
}
