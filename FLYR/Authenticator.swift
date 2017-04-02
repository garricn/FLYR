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
    func authenticate(with completion: @escaping (Authenticator.AuthResponse) -> Void)
}

class Authenticator: Authenticating {
    
    enum AuthResponse {
        case authenticated(CKReference)
        case notAuthenticated(Error)
    }

    private let container: Container

    init(defaultContainer: Container) {
        self.container = defaultContainer
    }
    
    func authenticate(with completion: @escaping (Authenticator.AuthResponse) -> Void) {
        container.fetchUserRecordID { response in
            switch response {
            case .successful(let any):
                guard let recordID = any as? CKRecordID else { return }
                let reference = CKReference(recordID: recordID, action: .none)
                let response = Authenticator.AuthResponse.authenticated(reference)
                completion(response)
            case .notSuccessful(let error):
                let response = Authenticator.AuthResponse.notAuthenticated(error)
                completion(response)
            }
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
